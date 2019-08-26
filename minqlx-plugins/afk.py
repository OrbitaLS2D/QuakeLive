### made by rcb for orbital

import minqlx

class afk(minqlx.Plugin):
    def __init__(self):
        self.add_command('afk', self.cmd_afk)
        return

    def cmd_afk(self, player, msg, channel):
        player.put("spectator")
        player.clan = "afk"
        return