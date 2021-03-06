---
layout: post
title: Writing a Discord bot in Go
---

About a month ago I decided to get into Go a bit. It's always kind of been an interesting programming language since it's modern, simple and has quite powerful multi-threading capabilities, most of which I have yet to use. I was asked if I could program a Discord bot that would print the weekly Covid-19 incidence numbers in Germany and I thought that's a great idea, so here we are.

You can find the source code for this bot [here](https://github.com/Witcher01/discord_covid19). I thought I'd share it since I put in a bit of work recently.

## Prerequisites

For this Discord bot I've used the Discord library [discordgo](https://github.com/bwmarrin/discordgo), it's "extension" [dgc](https://github.com/lus/dgc) to structure my code better and, most important of all, the REST API I used is [rki-covid-api](https://github.com/marlon360/rki-covid-api).  
Since the API can be self-hosted easily with Docker, I decided to do exactly that. You can find this over at [[https://rkiapi.wiredspace.de/]]

## Writing the code

### The API

The [API](https://github.com/marlon360/rki-covid-api) is fairly easy to use. So far the only thing I've been implementing is the ["districts"](https://rkiapi.wiredspace.de/districts) endpoint, which is well structured.

The response is structured in _data_. Each state has it's own _AGS_ ("Allgemeiner Gemeinde Schlüssel", essentially an ID for each district), which is how it's identified. Besides that, the districts contain information about their _name_, _population_, _weekIncidence_, _deaths_, etc.  
The one I'll be focusing on is the _weekIncidence_ field since this was what I originally built my bot around.

I ran into a bit of trouble deserializing the JSON you got from the API since I wasn't familiar with the Go way of doing this. The problem I had was that the fields of the _data_ response aren't static; they are the _AGS_ returned by the API.  
As it turns out this is easily handled. I declared the reponse I get as the following:

	type DistrictResponseData struct {
		Data map[string]DistrictResponse `json:"data"`
		Meta []MetaResponse              `json:"meta"`
	}

The `Data` field contains the districts which are identified by the _AGS_. Simply mapping _string_ to the struct for the district did the job.  
Deserializing the object turned out to be a bit weird, but it's fine overall:

	var drd DistrictResponseData
	// initialize a (hopefully) big enough map
	// api contains about 410 districts
	drd.Data = make(map[string]DistrictResponse, 410)

I initialize a struct for the response and can't call `json.Unmarshal` directly on that struct, I need to call it on the _Data_ field of it. This is the only I've managed to get it working, maybe you can find another one that might be more elegant. This works though so I won't complain.  
After this I just query the API for a reponse and call `err = json.Unmarshal(responseData, &drd)` on the reponse body. This fills the _drd_ variable with all the district data.

That's all you should need to know about the API.

### The Discord libraries

#### [discordgo](https://github.com/bwmarrin/discordgo)

The [discordgo](https://github.com/bwmarrin/discordgo) library is fairly easy to use. As with any other go package you can find the documentation on [[https://pkg.go.dev/github.com/bwmarrin/discordgo]].

To use this library you create a _discordgo.Session_ that will handle all the interaction with the Discord servers.  
For basic usage on this library I recommend having a look at the [examples](https://github.com/bwmarrin/discordgo/tree/master/examples) from their GitHub repo. They teach the basics well enough for use with the other Discord library I'm using.

#### [dgc](https://github.com/lus/dgc)

[dgc](https://github.com/lus/dgc) is an extension of the [discordgo](https://github.com/bwmarrin/discordgo) library. It uses that one to offer more functionality and better usability, as I'll show you in this section.  
As usual, you can find the documentation on [[https://pkg.go.dev/github.com/Lukaesebrot/dgc]].

With [discordgo](https://github.com/bwmarrin/discordgo) you need to register a handler and handle the incoming messages yourself. This includes argument parsing.  
Obviously this gets very boring really quickly, so I started using [dgc](https://github.com/lus/dgc). [dgc](https://github.com/lus/dgc), which lets you define command handlers that get called for specific commands for which you can even set up aliases.  
For basic usage, again, I recommend you to look at their [examples](https://github.com/lus/dgc/tree/master/examples). The _basic.go_ example should be all you need for now.

Initializing this library is done via the `dgc.Create()` function. It takes a _dgc.Router_ as an argument, which is initialized with the _Prefixes_, among other things.  
Registering commands to this _router_ is done via `router.RegisterCmd()`, which takes a _dgc.Command_ as an argument. With a _Command_ you can specify _Name_, _Description_, _Usage_, a _Handler_ and more. The Handler will be a function with a Signature of `func(*Ctx)`, meaning that it takes a context through which you will be able to send messages.

[dgc](https://github.com/lus/dgc) provides a default help handler which you can register via `router.RegisterDefaultHelpCommand(s, nil)`, where _s_ is the _discordgo.Session_.  
This help handler needs the reaction intent since the user will be able to flip through "pages" of the helper on discord, which is done via reactions.  
The intents I assigned the bot are the following:

	discord.Identify.Intents = discordgo.IntentsGuildMessages | discordgo.IntentsGuildMessageReactions

This let's you reply to incoming messages and react to reactions.

Sending messages is really easy. When one of the command handlers is being called they will have the _Ctx_ available as a parameter. This _Ctx_ presents you with 3 methods:

- `RespondText(string)`
- `RespondEmbed(*discordgo.MessageEmbed)`
- `RespondEmbedText(string, *discordgo.MessageEmbed)`

These are fairly self-explanatory by themselves.

Creating an embedded message is pretty simple, too. You just create a `discordgo.MessageEmbed` struct and fill out its members. Not all members have to be assigned something:

	embed := discordgo.MessageEmbed{
		Title:       "Removed districts",
		Timestamp:   time.Now().Format(time.RFC3339),
		Description: strings.Join(names, ", "),
	}

This is an excerpt from my code. It defines a _Title_, a _Timestamp_ and a _Description_ for the embedded message. Note that the _Timestamp_ needs to be in _RFC3339_ format. If that's not the case you will get an error when sending the embed.  
Sending it is as easy as doing `ctx.RespondEmbed(&embed)`.  
Sending messages can throw an error so you should catch that and log it somewhere.
