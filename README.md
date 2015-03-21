# hubot-cifsify
Hubot script to listen for Windows share paths and convert them to clickable cifs:// links

**Full disclosure:** This was mostly made as a silly proof-of-concept project to see what it's like to make a hubot-script. It's probably not all that useful to most people, but I figured I'd share it just in case.

Background:
I work at an organization where Mac users and Windows users collaborate via chat (in our case Slack). We have lots of legacy files on a Windows shared drive, and sometimes people reference those files by copy/pasting the Windows-flavored locations into chat messages (i.e. `\\someserver\someshare\file.txt`). It's lukewarm annoying to open this on a Mac, because I have to convert the slashes, so I wrote this hubot-script to listen for these kinds of Windows shared file paths and convert it into a click-friendly `cifs://someserver/someshare/file.txt` reference.

The regex matching I'm doing is a little wonky, because I wanted the ability to match these shared paths *within* other unrelated text... and if the path happens to contain spaces, boundaries get a little ambiguous. As a compromise, I allow spaces if there's an obvious file extension (i.e. `\\someserver\someshare\file with spaces.txt`), and don't if there's not (i.e. `\\someserver\someshare\this will not work\file.txt`).

Feedback and PR's are welcome, but again, this is mostly a rinky-dink demo to kick the tires on hubut scripts.
