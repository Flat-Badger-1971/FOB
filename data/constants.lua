_G.FOB = {
    -- for some reason using SI_GAMECAMERAACTIONTYPEs does not work in some languages
    Actions = {
        Catch = GetString(_G.FOB_CATCH),
        Collect = GetString(_G.FOB_COLLECT),
        Examine = GetString(_G.FOB_EXAMINE),
        Search = GetString(_G.FOB_SEARCH),
        Take = GetString(_G.FOB_TAKE),
        Talk = GetString(_G.FOB_TALK),
        Open = GetString(_G.FOB_OPEN),
        Use = GetString(_G.FOB_USE)
    },
    BladeOfWoe = GetAbilityName(78219),
    Bookshelf = GetString(_G.FOB_BOOKSHELF),
    CheeseIcons = {
        "/esoui/art/icons/housing_bre_inc_cheese001.dds",
        "/esoui/art/icons/quest_trollfat_001.dds",
        "/esoui/art/icons/quest_critter_001.dds",
        "/esoui/art/icons/ability_1handed_004.dds",
        "/esoui/art/icons/adornment_uni_radiusrebreather.dds"
    },
    CoffeeIcons = {
        "/esoui/art/icons/crafting_coffee_beans.dds",
        "/esoui/art/icons/housing_orc_inc_cupbone001.dds",
        "/esoui/art/icons/crowncrate_magickahealth_drink.dds"
    },
    DarkBrotherhood = GetString(_G.FOB_DARK_BROTHERHOOD),
    DefIds = {
        Bastian = 1,
        Mirri = 2,
        Ember = 5,
        Isobel = 6,
        Sharp = 8,
        Azander = 9,
        Tanlorin = 12,
        Zerith = 13
    },
    Exceptions = {
        [GetString(_G.FOB_LADY_LLARELS_SHELTER) or "nil"] = true,
        [GetString(_G.FOB_BLACKHEART_HAVEN) or "nil"] = true,
        [GetString(_G.FOB_SHINYTRADE) or "nil"] = true
    },
    FlyingInsects = {
        [GetString(_G.FOB_BLACKREACH_JELLY)] = true,
        [GetString(_G.FOB_BRIGHT_MOONS_LUNAR_MOTH)] = true,
        [GetString(_G.FOB_BUTTERFLY)] = true,
        [GetString(_G.FOB_CAVE_JELLY)] = true,
        [GetString(_G.FOB_DRAGONFLY)] = true,
        [GetString(_G.FOB_FETCHERFLY)] = true,
        [GetString(_G.FOB_FLESHFLIES)] = true,
        [GetString(_G.FOB_ISLAND_MOTH)] = true,
        [GetString(_G.FOB_MOON_KISSED_JELLY)] = true,
        [GetString(_G.FOB_NETCH_CALF)] = true,
        [GetString(_G.FOB_SEHTS_DOVAH_FLY)] = true,
        [GetString(_G.FOB_SWAMP_JELLY)] = true,
        [GetString(_G.FOB_TORCHBUG)] = true,
        [GetString(_G.FOB_WAFT)] = true,
        [GetString(_G.FOB_WASP)] = true,
        [GetString(_G.FOB_WINTER_MOTH)] = true
    },
    Functions = {},
    Illegal = {
        [GetString(_G.SI_GAMECAMERAACTIONTYPE20)] = true, -- Steal From
        [GetString(_G.SI_GAMECAMERAACTIONTYPE21)] = true, -- Pickpocket
        [GetString(_G.SI_GAMECAMERAACTIONTYPE23)] = true -- Trespass
    },
    LC = _G.LibFBCommon,
    LF = string.char(10),
    Logo = "FOB/assets/FOB.dds",
    LogoBlock = "FOB/assets/fobBlock.dds",
    MagesGuild = GetString(_G.FOB_MAGES_GUILD),
    MirriInsects = {
        [GetString(_G.FOB_BUTTERFLY)] = true,
        [GetString(_G.FOB_TORCHBUG)] = true
    },
    Mushrooms = {
        [GetString(_G.FOB_BLANCHED_RUSSULA_CAP)] = true,
        [GetString(_G.FOB_BLIGHT_BOG_MUSHROOM)] = true,
        [GetString(_G.FOB_BLUE_ENTOLOMA)] = true,
        [GetString(_G.FOB_CALDERA_MUSHROOM)] = true,
        [GetString(_G.FOB_CANIS_CAP_MUSHROOM)] = true,
        [GetString(_G.FOB_DUSK_MUSHROOM)] = true,
        [GetString(_G.FOB_EMETIC_RUSSULA)] = true,
        [GetString(_G.FOB_GLEAMCAP)] = true,
        [GetString(_G.FOB_GLOOM_MOREL)] = true,
        [GetString(_G.FOB_GLOOMSPORE_AGARIC)] = true,
        [GetString(_G.FOB_GRAVEN_CAP)] = true,
        [GetString(_G.FOB_IMP_STOOL)] = true,
        [GetString(_G.FOB_IRONSTALK_MUSHROOM)] = true,
        [GetString(_G.FOB_KWAMA_CAP)] = true,
        [GetString(_G.FOB_LAVANDER_CAP)] = true,
        [GetString(_G.FOB_LUMINOUS_RUSSULA)] = true,
        [GetString(_G.FOB_NAMIRAS_ROT)] = true,
        [GetString(_G.FOB_PARASOL_LICHEN)] = true,
        [GetString(_G.FOB_PRUNE_MOREL_MUSHROOM)] = true,
        [GetString(_G.FOB_STINKHORN)] = true,
        [GetString(_G.FOB_VIOLET_COPRINUS)] = true,
        [GetString(_G.FOB_WHITE_CAP)] = true
    },
    Name = "FOB",
    Nirnroot = GetString(_G.FOB_NIRNROOT),
    NoPickPocketing = {},
    OutlawsRefuge = {
        [GetString(_G.FOB_OUTLAWS_REFUGE):lower()] = true,
        [GetString(_G.FOB_THIEVES_DEN):lower()] = true
    },
    Treasures = {
        [GetString(_G.FOB_RITUAL)] = true,
        [GetString(_G.FOB_MEDICAL)] = true
    }
}

