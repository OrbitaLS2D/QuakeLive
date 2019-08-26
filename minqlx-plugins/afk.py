import minqlx

class afk(minqlx.Plugin):
    def __init__(self):
        self.add_command('afk', self.cmd_afk)
        return

    def cmd_afk(self, player, msg, channel):
        #Get the player client ID who invoked this command
        playerClientID = player.id

        #Define the UserInfo ConfigString for the player
        userInfoConfigStringIndex = 529 + playerClientID

        #If the player invokes this command while in-game, put the player in team spec
        minqlx.console_command('put s ' + str(playerClientID))

        #Get the current UserInfo ConfigString data for this player, and parse it into a dictionary
        userInfoConfigString = minqlx.parse_variables(minqlx.get_configstring(userInfoConfigStringIndex), ordered=True)

        #Set the Clan Tag and Clan Name for this player to 'afk'
        userInfoConfigString['xcn'] = userInfoConfigString['cn'] = 'afk'

        #Convert the dictionary back to a string in the QL format for ConfigStrings
        modified_userInfoConfigString = ''.join(['\\{}\\{}'.format(k, userInfoConfigString[k]) for k in userInfoConfigString])

        #Set the modified UserInfo ConfigString
        minqlx.set_configstring(userInfoConfigStringIndex, modified_userInfoConfigString)
        return