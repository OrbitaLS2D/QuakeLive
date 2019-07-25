#Import our mockminqlx if executing this plugin script directly
#Add mockminqlx.py in the same directory as your MyPlugin.py
if __name__ == "__main__":
    import mockminqlx

from datetime import datetime
from minqlx import *

class MyPlugin(Plugin):
    def __init__(self):
        self.Cvar01 = self.get_cvar("qlx_MyPlugin_Cvar01")
        self.Cvar02 = self.get_cvar("qlx_MyPlugin_Cvar02")

        self.add_command('blah', self.cmd_blah)
        self.add_hook('client_command', self.handle_client_command)

    def cmd_blah(self, player, msg, channel):
        player.tell(msg)

    def handle_client_command(self, player, cmd):
        if cmd in 'say_team blah':
            player.tell('ClientCommand superblah')

    def test_minqlx_get_configstring(self, index):
        return minqlx.get_configstring(index)

    def test_minqlx_players_info(self):
        return minqlx.players_info()

#Lets step through our plugin with a debugger!
#Add some breakpoints
if __name__ == "__main__":

    #New up our minqlx plugin
    mp = MyPlugin()
    
    #Trigger our plugin command as if minqlx did it
    mp.cmd_blah(minqlx.Player(2),'!blah arg1 arg2', None)
    
    #Trigger our plugin hook as if minqlx did it
    mp.handle_client_command(minqlx.Player(2),'say_team blah')

    #Test minqlx.get_configstring to see if its return our test data
    ret = mp.test_minqlx_get_configstring(0)
    print(type(ret))
    print(repr(ret))

    #Test minqlx.players_info()
    ret = mp.test_minqlx_players_info()
    print(type(ret))
    print(repr(ret))
