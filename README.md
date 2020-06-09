# PrivateTouchType
Touch type keyboard component

Subject to MIT license

Get in touch if you feel this project is useful for you.

Background
==========
Should we be concerned about the risk of others being able to filter and monitor what we type? When it comes to obvious things like login id's, passwords, bank and credit card information etc, of course we should be concerned. We know that information is collected from our online browsing by cookies, pooled by various companies (link to article on cookie abuse) and used to profile our interests for marketing purposes. Is it possible or likely that Microsoft, Google, Apple or device manufacturers will monitor what we type today or might be tempted to do so in the future?

The technology world makes some big mistakes. Back in the 80's when PC's first appeared somebody decided that when you press the letter A on a keyboard it returns the value 65 to whichever application is asking. That principle is still true today, every flavour of MS-DOS and subsequently Windows does the same and will continue to do so. The values follow the ASCII and Unicode character code structure which means that the upper case letters A-Z are values 65 to 91, space bar is 32 and * is 42 etc, etc, etc.

So, why a mistake? It means that even the most inexperienced developer can write a small program which can run on a PC and monitor what you type. This has given birth to many viruses and similar programs which are used to recognize and capture passwords, card numbers and other personal and private information. The fact that we might want the entry of data to be secure and private was not considered or was considered and decided to not be important enough to warrant additional design originally. The same "capture" method can be used for marketing purposes to track and identify our interests for others financial gain.

It is only fair to point out that there are many applications that also rely on this ability. The issue is not that “it can be done” but that there are no controls or ability to change it. Whether we want to do something about it or not does not matter. It is too late. If anyone tried to change this fundamental keyboard behaviour the result would be that many, if not all Windows applications would need to change accordingly and that is a non-starter.

Physical keyboards are electronic, are supplied by many different manufacturers and have no ability to do anything other than identify which key is pressed. "Touch keyboards" add a new dimension to the issue and increasingly we use touch screens to type rather than use a physical keyboard. The ones we use on our devices are provided by Microsoft (Windows), Google (Android), Apple (IOS) and a limited number of phone manufacturers and a few other providers.

These touch keyboards are all "applications" and there is nothing to stop any of those organisations filtering what we type for any purpose they want.

Let me use a "chat" app as an example. Whilst communication maybe encrypted "end to end" and therefore secure and private, everything we type/touch is provided "key by key" to the program running on your phone or tablet by the operating system, Android, IOS and Windows. The operating system or keyboard module has the "key value" first, so can record and do what it wants with it before it is passed to the  application. Once the app is given the "key value" it is secure from the apps point of view from unknown third parties but not from the device manufacturer or operating system provider.

But we can do something to stop what we type on "touch keyboards" from being abused, or at least developers that create applications can. It will not stop organisations from using data it collects but it will make it much more difficult or impossible for those organisations to be able to, if they ever choose to do so.

Faced with a need to provide security and privacy when using a touch keyboard for my own applications I started project PrivateTouchType (PTT). Now it is time to share it with others.

PTT is a toolkit for other software developers to use. Initially supporting the Embarcadero Delphi language (VCL and FMX), followed by Lazarus (a Pascal cousin) and most likely followed by a C# .Net version. As this toolkit is for open source use other developers are welcome to port to other languages and get involved with what has been developed so far. This means that application developers can present their own touch keyboard(s) in their application independently of the "default" one on the device or development environment. The toolkit is "source code" not a finished EXE or DLL, so all the code is transparent and can be examined for trust purposes by the development community and others.
