from types import ModuleType
import sys

#The PlayerInfo object is generated in C
#Lets reproduce the basic structure
#see https://github.com/MinoMino/minqlx/blob/master/python_embed.c#L86
class PlayerInfo:
    def __init__(self, client_id, name, connection_state, userinfo, steam_id, team, privileges):
        self.d = [client_id, name, connection_state, userinfo, steam_id, team, privileges]
        self.client_id=client_id
        self.name=name
        self.connection_state=connection_state
        self.userinfo=userinfo
        self.steam_id=steam_id
        self.team=team
        self.privileges=privileges
    def __getitem__(self, key):
        return self.d[key]
    def __repr__(self):
        return repr(self.d)

#The minqlx object is generated in C
#Lets reproduce some basic structures
#that our plugin uses, along with test data
#so our plugin functions the same as if it was
#receiving actual game data
#see https://github.com/MinoMino/minqlx/blob/master/python_embed.c#L1907
class minqlx:

    #minqlx constants, lets define a couple as an example
    #see https://github.com/MinoMino/minqlx/blob/master/python_embed.c#L1801
    #and https://github.com/MinoMino/minqlx/blob/master/pyminqlx.h#L29
    PRI_HIGHEST = 0
    PRI_NORMAL = 1

    #The Plugin object all minqlx plugins must inherit from
    #Add w/e you need
    #see https://github.com/MinoMino/minqlx/blob/master/python/minqlx/_plugin.py#L22
    class Plugin:
        def add_command(self, *args):
            print(repr(args))
        def add_hook(self, *args):
            print(repr(args))
        @classmethod
        def get_cvar(cls, name, return_type=str):
            res = minqlx.get_cvar(name)
            if return_type == str:
                return res
            elif return_type == int:
                return int(res)
            elif return_type == float:
                return float(res)
            elif return_type == bool:
                return bool(int(res))
            elif return_type == list:
                return [s.strip() for s in res.split(",")]
            elif return_type == set:
                return {s.strip() for s in res.split(",")}
            elif return_type == tuple:
                return tuple([s.strip() for s in res.split(",")])
            else:
                raise ValueError("Invalid return type: {}".format(return_type))
        @classmethod
        def set_cvar(cls, name, value, flags=0):
            if cls.get_cvar(name) is None:
                minqlx.set_cvar(name, value, flags)
                return True
            else:
                minqlx.console_command("{} \"{}\"".format(name, value))
                return False
        @classmethod
        def tell(cls, msg, recipient, **kwargs):
            print(msg, recipient, **kwargs)

    class Player:
        def __init__(self, client_id, info=None):
            self._valid = True
            if info:
                self._id = client_id
                self._info = info
            else:
                self._id = client_id
                self._info = minqlx.player_info(client_id)
                if not self._info:
                    self._invalidate("Tried to initialize a Player instance of nonexistant player {}.".format(client_id))
            self._userinfo = None
            self._steam_id = self._info.steam_id
            if self._info.name:
                self._name = self._info.name
            else:
                self._userinfo = minqlx.parse_variables(self._info.userinfo, ordered=True)
                if "name" in self._userinfo:
                    self._name = self._userinfo["name"]
                else:
                    self._name = ""
        def _invalidate(self, e="The player does not exist anymore. Did the player disconnect?"):
                self._valid = False

        def tell(self, msg, **kwargs):
            return minqlx.Plugin.tell(msg, self, **kwargs)

    #see https://github.com/MinoMino/minqlx/blob/master/python_embed.c#L291
    def players_info(): return [
        None, None
        ,PlayerInfo(client_id=2,name='Player02',connection_state=4,userinfo='\\ip\\0.0.0.0:0\\ui_singlePlayerActive\\0\\cg_autoAction\\2\\cg_autoHop\\1\\cg_redictItems\\0\\model\\sarge\\headmodel\\ranger/sport_red\\cl_anonymous\\0\\country\\US\\color1\\21\color2\\8\\sex\\male\\teamtask\\0\\rate\\25000\\name\\Player02\\handicap\\100',steam_id=20000000000000002,team=2,privileges=0)
        ,PlayerInfo(client_id=3,name='player03',connection_state=4,userinfo='\\steam\\30000000000000003\\ip\\0.0.0.0:0\\challenge\\1371994069\\qport\\20554\\protocol\\91\\ui_singlePlayerActive\\0\\cg_autoHop\\1\\cg_predictItems\\1\\model\\uriel/default\\headmodel\\james\\cl_anonymous\\0\\name\\player03\\rate\\25000\\teamtask\\0\\sex\\male\\color2\\25\\color1\\6\\country\\ua\\handicap\\100',steam_id=30000000000000003,team=1,privileges=0)
        ,PlayerInfo(client_id=4,name='player04',connection_state=4,userinfo='\\ip\\0.0.0.0:0\\ui_singlePlayerActive\\0\\cg_autoAction\\3\\cg_autoHop\\1\\cg_pedictItems\\0\\model\\ranger/default\\headmodel\\doom/blue\\cl_anonymous\\0\\color1\\13\\color2\\13\\sex\\male\\teamtask\\0\\rate\\25000\\country\\US\\name\\player04\\handicap\\100',steam_id=40000000000000004,team=2,privileges=0)
        ,PlayerInfo(client_id=5,name='player05',connection_state=4,userinfo='\\ip\\0.0.0.0:0\\ui_singlePlayerActive\\0\\cg_autoAction\\3\\cg_autoHop\\1\\cg_predictItems\\1\\model\\sarge\\headmodel\\sarge\\cl_anonymous\\0\\country\\US\\color1\\7\\color2\\25\\sex\\male\\teamtask\\0\\rate\\25000\\name\\player05\\handicap\\100',steam_id=50000000000000005,team=1,privileges=0)
        ,PlayerInfo(client_id=6,name='player06',connection_state=4,userinfo='\\ip\\0.0.0.0:0\\ui_singlePlayerActive\\0\\cg_autoAction\\0\\cg_autoHop\\1\\cg_predictItems\\0\\model\\ranger/default\\headmodel\\sarge\\cl_anonymous\\0\\country\\US\\color1\\1\\color2\\25\\sex\\male\\teamtask\\0\\rate\\25000\\name\\player06\\handicap\\100',steam_id=60000000000000006,team=3,privileges=0)
        ,PlayerInfo(client_id=7,name='player07',connection_state=4,userinfo='\\ip\\0.0.0.0:0\\ui_singlePlayerActive\\0\\cg_autoAction\\0\\cg_autoHop\\1\\cg_predictItems\\0\\model\\doom\\headmodel\\visor\\name\\player07\\cl_anonymous\\0\\handicap\\100\\sex\\male\\teamtask\\0\\rate\\25000\\color2\\18\\color1\\15\\country\\US',steam_id=70000000000000007,team=1,privileges=0)
        ,PlayerInfo(client_id=8,name='player08',connection_state=4,userinfo='\\steam\\80000000000000008\\ip\\0.0.0.0:0\\challenge\\287696655\\qport\\65377\\protocol\\91\\ui_singlePlayerActive\\0\\cg_autoAction\\3\\cg_autoHop\\1\\cg_predictItems\\1\\model\\oom\\headmodel\\doom\\cl_anonymous\\0\\country\\US\\color1\\7\\color2\\22\\sex\\male\\teamtask\\0\\rate\\25000\\name\\player08\\handicap\\100',steam_id=80000000000000008,team=3,privileges=0)
        ,PlayerInfo(client_id=9,name='player09', connection_state=4,userinfo='\\ip\\0.0.0.0:0\\ui_singlePlayerActive\\0\\cg_autoAction\\2\\cg_autoHop\\0\\cg_predictItems\\0\\model\\biker/stroggo\\headmodel\\sarge\\name\\player09\\cl_anonymous\\0\\country\\US\\rate\\25000\\teamtask\\0\\sex\\male\\color2\\24\\color1\\1\\handicap\\100',steam_id=90000000000000009,team=2,privileges=0)
        ,PlayerInfo(client_id=10,name='player10',connection_state=4,userinfo='\\steam\\10000000000000010\\ip\\0.0.0.0:0\\challenge\\1925257625\\qport\\21066\\protocol\\91\\ui_singlePlayerActive\\0\\cg_autoHop\\1\\cg_predictItems\\1\\model\\sarge\\headmodel\\uriel/default\\handicap\\100\\name\\player10\\cl_anonymous\\0\\rate\\25000\\teamtask\\0\\sex\\male\\color2\\1\\color1\\5\\country\\US',steam_id=10000000000000010,team=2,privileges=0)
        ,PlayerInfo(client_id=11,name='player11',connection_state=4,userinfo='\\ip\\0.0.0.0:0\\ui_singlePlayerActive\\0\\cg_autoAction\\3\\cg_autoHop\\0\\cg_predictItems\\1\\model\\slash/yuriko\\headmodel\\bones\\cl_anonymous\\0\\rate\\25000\\teamtask\\0\\sex\\male\\color2\\13\\color1\\13\\country\\usa\\name\\player11\\handicap\\100',steam_id=11000000000000011,team=1,privileges=0)
        ,None,None,None,None,None,None,None,None,None,None,None,None,None,None,None,None,None,None,None,None
    ]

    def player_info(client_id):
        for i in minqlx.players_info():
            if not i: continue
            if i[0] == client_id:
                return i
        return None

    #cvar dict, add your own test data
    _cvars = {
        'qlx_MyPlugin_Cvar01': '01',
        'qlx_MyPlugin_Cvar02': '02', 
    }

    #see https://github.com/MinoMino/minqlx/blob/master/python_embed.c#L417
    def get_cvar(name):
        return minqlx._cvars[name]

    #see https://github.com/MinoMino/minqlx/blob/master/python_embed.c#L436
    def set_cvar(name, value, flags):
        minqlx._cvars[name] = value

    def console_command(cmd):
        print('console_command', cmd)

    #see https://github.com/MinoMino/minqlx/blob/master/python_embed.c#L530
    def get_configstring(index):
        if index == 663:
            return 3 #663 is Red Team Player Count
        if index == 664:
            return 4 #663 is Blue Team Player Count
        if index == 0: #0 is ServerInfo
            return "\\g_customSettings\\0\\g_levelStartTime\\1563667531\\g_adCaptureScoreBonus\\3\\g_adElimScoreBonus\\2\\g_adTouchScoreBonus\\1\\capturelimit\\8\\dmflags\\28\\g_factory\\ca\\g_factoryTitle\\Clan Arena\\fraglimit\\50\\g_freezeRoundDelay\\4000\\g_gameState\\IN_PROGRESS\\g_gametype\\4\\g_gravity\\800\\g_instaGib\\0\\g_itemHeight\\35\\g_itemTimers\\1\\g_loadout\\0\\sv_maxclients\\32\\mercylimit\\0\\g_needpass\\0\\g_overtime\\0\\g_quadDamageFactor\\3\\g_roundWarmupDelay\\10000\\roundlimit\\10\\roundtimelimit\\120\\scorelimit\\150\\g_startingHealth\\200\\g_teamForceBalance\\1\\teamsize\\4\\g_teamSizeMin\\1\\timelimit\\0\\g_timeoutCount\\0\\g_voteFlags\\0\\g_weaponRespawn\\5\\sv_hostname\\[GA] Mega's Massacre\\sv_privateClients\\2\\version\\1069 linux-x64 Jun  3 2016 20:53:50\\protocol\\91\\mapname\\overkill\\bot_minplayers\\0"
        if 529 <= index < 529 + 64: #529 to 593 is UserInfo
            if index - 529 == 6: #Our plugin queried my client userinfo (different from server userinfo)
                return "\\n\\player06\\t\\2\\model\\ranger/default\\hmodel\\sarge\\c1\\1\\c2\\25\\hc\\200\\w\\0\\l\\0\\tt\\0\\tl\\1\\rp\\0\\p\\0\\so\\0\\pq\\0\\st\\60000000000000006\\c\\US\\xcn\\test\\cn\\test"

    def parse_variables(varstr, ordered=False):
        if ordered:
            res = collections.OrderedDict()
        else:
            res = {}
        if not varstr.strip():
            return res
        vars = varstr.lstrip("\\").split("\\")
        try:
            for i in range(0, len(vars), 2):
                res[vars[i]] = vars[i + 1]
        except IndexError:
            print("Uneven number of keys and values: {}".format(varstr))
        return res

#Do some module hackery so our plugin does not import minqlx proper
moduleminqlx = ModuleType('minqlx')
sys.modules[moduleminqlx.__name__] = moduleminqlx
moduleminqlx.__file__ = moduleminqlx.__name__ + '.py'
moduleminqlx.minqlx = minqlx
moduleminqlx.Plugin = minqlx.Plugin
moduleminqlx.Player = minqlx.Player
