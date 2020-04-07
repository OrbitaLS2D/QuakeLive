#
#
#  orbFun by OrbitaL
#  Misc commands for nothing really :P
#  IDC whut you do with this code :P
#  I stole most of it :P
#
#



import minqlx

class orbFun(minqlx.Plugin):
    def __init__(self):
        self.add_command(("centerprint","cp"), self.cmd_centerprint, 2)
        self.add_command(("spec999","999"), self.cmd_spec999, 2)
        self.add_command(("ragespec","spec") self.cmd_ragespec)
    
        def cmd_centerprint(self, player, msg, channel):
        message_string = ""
        for i in range(1, len(msg)): message_string += str(msg[i]) + " "
        self.center_print(message_string)
        
        def cmd_spec999(self, player, msg, channel):
        for p in self.players():
            if p.ping >= 990:
                if p.team != "spectator":
                    p.put("spectator")
                    self.msg("spec999: Moving {} to spectators.".format(p.clean_name))
                    
        def cmd_ragespec(self, player, msg, channel):
        if self.game.state == "in_progress" and player.team != "spectator":
            player.put("spectator")
            self.msg("{} ^1rage^7specs".format(player.name))                    
