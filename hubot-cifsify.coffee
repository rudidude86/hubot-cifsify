# Description:
#   Listen for links to Windows shared folders and convert it to cifs://... links for easy clicking on Mac OS X (and maybe other platforms?)
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_WINDOWS_SHARED_DRIVES
#
#   This should be a JSON mapping of drive letter to server/share resources
#   i.e. '{ "Z": {"server" : "servername", "share" : "sharename"} }'
#
# Author:
#   Ryan Rud
#
#
# My org sets up default letters to certain shared drives. Maybe yours does too!
#
# Convert windows shared drives into cifs links:
#
#   Z:\file.txt                         => cifs://servername/sharename/file.txt
#
#   Z:\file with spaces.txt             => cifs://servername/sharename/file%20with%20spaces.txt
#
#   \\servername\sharename\file.txt     => cifs://servername/sharename/file.txt
#
#   \\servername\sharename\file.txt     => cifs://servername/sharename/file.txt
#

# Regex to match Windows shared drive paths
windowsPathRegex = ///
  (                       #  (group 1)
    (                     #  (group 2)
      (                   #  (group 3)
        [A-Z]             # Drive letter
      )                   #  (/group 3)
      \:\\                # Initial colon and backslash after drive letter
    )                     #  (/group 2)
    |                     # -or-
    (                     #  (group 4)
      \\\\                # Double backslash prefixing windows server name
      (                   #  (group 5)
        [A-Za-z]+         # Windows server name
      )                   #  (/group 5)
      \\                  # Backslash between server name and share name
      (                   #  (group 6)
        [A-Za-z]+         # Share name
      )                   #  (/group 6)
    )                     #  (/group 4)
  )                       #  (/group 1)
  (                       #  (group 7)
    [^\s]+                 # Space-free filename with no file extension
    |                     # -or-
    .*\.[A-Za-z0-9]{3,4}  # Space-infested filename with file extension
  )                       #  (/group 7)
  ?                       # Make path part optional
///

module.exports = (robot) ->

  robot.hear windowsPathRegex, (msg) ->

    drives = process.env.HUBOT_WINDOWS_SHARED_DRIVES or "{}"

    try
      drives = JSON.parse(drives)
    catch e
      return

    driveLetter = msg.match[3]
    serverName = msg.match[5]
    shareName = msg.match[6]

    # If it looked like a mounted drive letter, try to look it up
    if driveLetter && !serverName && !shareName
      if !drives
        return

      mount = drives[driveLetter]
      if !mount
        return
      serverName = mount.server
      shareName = mount.share

    if !serverName || !shareName
      return

    # Convert various characters in path ( "\" --> "/", " " --> "%20")
    path = msg.match[7].replace(/\\/g, '/').replace(/\ /g, '%20')
    uri = "cifs://#{serverName}/#{shareName}/#{path}"
    msg.send "Allow me to _cifs-ify_ that for you! #{uri}"
