--- @meta

CF = {}
DailyProvisioning = {}
LibAddonMenu2 = {}
LibChatMessage = {}
LibDebugLogger = {}
LibFBCommon = {}
LibSavedVars = {}
RETICLE = {}
RuEsoVariables = {}
ZO_ReticleContainer = {}
ZO_Provisioner = {}

ZO_SHARED_INFORMATION_AREA_SUPPRESSION_CATEGORIES = {}

--- @class MenuBar
--- @field m_object table

--- @class ModeBar
--- @field menuBar MenuBar
ModeBar = {}
--- @param fragmentId number
function ModeBar:SelectFragment(fragmentId) end

--- @class FENCE_KEYBOARD
--- @field modeBar ModeBar
FENCE_KEYBOARD = {}

--- @class FENCE_MANAGER
FENCE_MANAGER = {}
--- @param functionName string
--- @param callback function
function FENCE_MANAGER:RegisterCallback(functionName, callback) end

--- @class FISHING_MANAGER
FISHING_MANAGER = {}
function FISHING_MANAGER:StopInteraction() end

--- @class INTERACTIVE_WHEEL_MANAGER
INTERACTIVE_WHEEL_MANAGER = {}
--- @param interactionType number
function INTERACTIVE_WHEEL_MANAGER:StopInteraction(interactionType) end

--- @class LOOT_SHARED
LOOT_SHARED = {}
--- @return table
function LOOT_SHARED:GetSortedLootData() end

--- @class LootButton
LootButton = {}
--- @param enabled boolean
function LootButton:SetEnabled(enabled) end

--- @class LOOT_WINDOW
LOOT_WINDOW = {}
--- @param keybind string|nil
--- @return LootButton
function LOOT_WINDOW:GetButtonByKeybind(keybind) end

--- @class PLAYER_INVENTORY
--- @field inventories table
--- @field isListDirty boolean
PLAYER_INVENTORY = {}
--- @param bagId number
function PLAYER_INVENTORY:RefreshAllInventorySlots(bagId) end

--- @class PROVISIONER
--- @field recipeTree ZO_Tree
PROVISIONER = {}

--- @class SHARED_INVENTORY
--- @field bagCache table
SHARED_INVENTORY = {}
--- @param functionName string
--- @param callback function
function SHARED_INVENTORY:RegisterCallback(functionName, callback) end

--- @class SHARED_INFORMATION_AREA
--- @field prioritizedVisibility ZO_PrioritizedVisibility
SHARED_INFORMATION_AREA = {}
--- @param object table
--- @param hidden boolean
function SHARED_INFORMATION_AREA:SetHidden(object, hidden) end

--- @param object table
--- @return boolean
function SHARED_INFORMATION_AREA:IsHidden(object) end

--- @return boolean
function SHARED_INFORMATION_AREA:IsSuppressed() end

--- @param suppressed boolean
--- @param categoriesMask number
--- @param descriptor string
function SHARED_INFORMATION_AREA:SetCategoriesSuppressed(suppressed, categoriesMask, descriptor) end

--- @class TEXT_SEARCH_MANAGER
TEXT_SEARCH_MANAGER = {}
--- @param functionName string
--- @param callback function
function TEXT_SEARCH_MANAGER:RegisterCallback(functionName, callback) end

--- @class UNIT_FRAMES
UNIT_FRAMES = {}
--- @param frameName string
--- @return Control
function UNIT_FRAMES:GetFrame(frameName) end

function Control:SetHiddenForReason(reason, hidden, customShowDuration, customHideDuration) end

--- @class ZO_ReticleContainerReticle
ZO_ReticleContainerReticle = {}
--- @param alpha number
function ZO_ReticleContainerReticle:SetAlpha(alpha) end

--- @class ZO_LootAlphaContainerListContents
ZO_LootAlphaContainerListContents = {}
--- @param rowNum number
function ZO_LootAlphaContainerListContents:GetChild(rowNum) end

--- @returns number
function ZO_LootAlphaContainerListContents:GetNumChildren() end

--- @param rowNum number
--- @returns Row
function ZO_LootAlphaContainerListContents:GetRow(rowNum) end

--- @param slotControl table
--- @param meetsUsageRequirements boolean
--- @param locked boolean
function ZO_PlayerInventorySlot_SetupUsableAndLockedColor(slotControl, meetsUsageRequirements, locked) end

--- @param icon string
function Control:AddIcon(icon) end

function Control:Hide() end

--- @param texture string
function Control:SetTexture(texture) end

--- @param font string
function Control:SetFont(font) end

--- @param red number
--- @param green number
--- @param blue number
--- @param alpha number
function Control:SetColor(red, green, blue, alpha) end

--- @param alignment number
function Control:SetHorizontalAlignment(alignment) end

--- @param alignment number
function Control:SetVerticalAlignment(alignment) end

--- @param text string
function Control:SetText(text) end

--- @param start number
--- @param finish number
function AnimationObject:SetAlphaValues(start, finish) end

--- @param scale number
function AnimationObject:SetStartScale(scale) end

--- @param scale number
function AnimationObject:SetEndScale(scale) end

function EndPendingInteraction() end

ADDITIONAL_INTERACT_INFO_FISHING_NODE = 3
ADDITIONAL_INTERACT_INFO_PICKPOCKET_CHANCE = 6
ANIMATION_ALPHA = 2
ANIMATION_PLAYBACK_ONE_SHOT = 0
ANIMATION_SCALE = 1
BAG_WORN = 0
BSTATE_DISABLED = 2
COMPANION_STATE_ACTIVE = 7
COMPANION_STATE_INITIALIZED_PENDING = 4
COMPANION_STATE_PENDING = 5
DL_CONTROLS = 1
EQUIP_SLOT_BACKUP_MAIN = 20
EQUIP_SLOT_BACKUP_OFF = 21
EQUIP_SLOT_BACKUP_POISON = 14
EQUIP_SLOT_COSTUME = 10
EQUIP_SLOT_MAIN_HAND = 4
EQUIP_SLOT_NECK = 1
EQUIP_SLOT_POISON = 13
EQUIP_SLOT_RING1 = 11
EQUIP_SLOT_RING2 = 12
GAMEPLAY_ACTOR_CATEGORY_PLAYER = 0
INTERACTION_BOOK = 12
INTERACTION_FISH = 24
INTERACTION_HARVEST = 28
INTERACTION_LOOT = 2
INTERACTION_NONE = 0
INVENTORY_BACKPACK = 1
ITEMTYPE_TREASURE = 56
ITEMTYPE_TROPHY = 5
LINK_STYLE_DEFAULT = 0
MONSTER_SOCIAL_CLASS_BEGGAR = 6
MONSTER_SOCIAL_CLASS_FISHER = 16
MONSTER_SOCIAL_CLASS_LABORER = 22
PICKPOCKET_DIFFICULTY_INVALID = 0
SI_COMPANION_NAME_FORMATTER = 0
SI_FENCE_LAUNDER_TAB = 0
SI_GAMECAMERAACTIONTYPE20 = 0
SI_GAMECAMERAACTIONTYPE21 = 0
SI_GAMECAMERAACTIONTYPE23 = 0
SI_RESTYLE_STATION_MENU_ROOT_TITLE = 0
SI_STORE_MODE_SELL = 0
SI_UNIT_FRAME_STATUS_SUMMONING = 0
SI_UNIT_NAME = 0
SPECIALIZED_ITEMTYPE_TROPHY_SCROLL = 105
ZO_COMMON_INFO_DEFAULT_GAMEPAD_BOTTOM_OFFSET_Y = -235
ZO_COMMON_INFO_DEFAULT_KEYBOARD_BOTTOM_OFFSET_Y = -210
ZO_INTERACTIVE_WHEEL_TYPE_FISHING = 3
ZO_INTERACTIVE_WHEEL_TYPE_UTILITY = 0

FOB_ALERT_COLOUR = 0
FOB_ALERT_FONT = 0
FOB_ALERT_ICON = 0
FOB_ALERT_SHADOW = 0
FOB_CHEESE_ALERT = 0
FOB_CHEESE_WARNING = 0
FOB_COFFEE_ALERT = 0
FOB_COFFEE_WARNING = 0
FOB_COMPANION_MENU = 0
FOB_DISABLE_COMPANION_INTERACTION = 0
FOB_DISABLED = 0
FOB_DISMISS_COMPANION = 0
FOB_ENABLED = 0
FOB_SHOWSUMMONING = 0
FOB_SUMMONING = 0
FOB_SUMMONINGCOLOUR = 0
FOB_TOGGLE = 0
FOB_TOGGLE_COMPANION = 0
FOB_WARNING = 0
FOB_CATCH = 0
FOB_COLLECT = 0
FOB_EXAMINE = 0
FOB_LOOT = 0
FOB_OPEN = 0
FOB_SEARCH = 0
FOB_TALK = 0
FOB_TAKE = 0
FOB_USE = 0
FOB_BOOKSHELF = 0
FOB_DARK_BROTHERHOOD = 0
FOB_MAGES_GUILD = 0
FOB_MEDICAL = 0
FOB_NIRNROOT = 0
FOB_OUTFIT_STATION = 0
FOB_OUTLAWS_REFUGE = 0
FOB_PSIJIC_PORTAL = 0
FOB_RITUAL = 0
FOB_THIEVES_DEN = 0
FOB_CADWELL = 0
FOB_IGNORE_INSECTS = 0
FOB_IGNORE_MIRRI_INSECTS = 0
FOB_IGNORE_ALL_INSECTS = 0
FOB_PREVENT_BLADE_OF_WOE = 0
FOB_PREVENT_BOOKSHELVES = 0
FOB_PREVENT_CADWELL = 0
FOB_PREVENT_CRIMINAL = 0
FOB_PREVENT_DARK_BROTHERHOOD = 0
FOB_PREVENT_EDICTS = 0
FOB_PREVENT_FENCE = 0
FOB_PREVENT_FISHING = 0
FOB_PREVENT_LOREBOOKS = 0
FOB_PREVENT_MAGES_GUILD = 0
FOB_PREVENT_MUSHROOM = 0
FOB_PREVENT_NIRNROOT = 0
FOB_PREVENT_OUTFIT = 0
FOB_PREVENT_OUTLAW = 0
FOB_PREVENT_PICKPOCKETING = 0
FOB_PREVENT_PSIJIC = 0
FOB_PREVENT_SPECIFIC_TT = 0
FOB_PREVENT_TREASURES = 0
FOB_BLACKREACH_JELLY = 0
FOB_BRIGHT_MOONS_LUNAR_MOTH = 0
FOB_BUTTERFLY = 0
FOB_CAVE_JELLY = 0
FOB_DRAGONFLY = 0
FOB_FETCHERFLY = 0
FOB_FLESHFLIES = 0
FOB_ISLAND_MOTH = 0
FOB_MOON_KISSED_JELLY = 0
FOB_NETCH_CALF = 0
FOB_SEHTS_DOVAH_FLY = 0
FOB_SWAMP_JELLY = 0
FOB_TORCHBUG = 0
FOB_WAFT = 0
FOB_WASP = 0
FOB_WINTER_MOTH = 0
FOB_BLANCHED_RUSSULA_CAP = 0
FOB_BLIGHT_BOG_MUSHROOM = 0
FOB_BLUE_ENTOLOMA = 0
FOB_CALDERA_MUSHROOM = 0
FOB_CANIS_CAP_MUSHROOM = 0
FOB_DUSK_MUSHROOM = 0
FOB_EMETIC_RUSSULA = 0
FOB_GLEAMCAP = 0
FOB_GLOOM_MOREL = 0
FOB_GLOOMSPORE_AGARIC = 0
FOB_GRAVEN_CAP = 0
FOB_IMP_STOOL = 0
FOB_IRONSTALK_MUSHROOM = 0
FOB_KWAMA_CAP = 0
FOB_LAVANDER_CAP = 0
FOB_LUMINOUS_RUSSULA = 0
FOB_NAMIRAS_ROT = 0
FOB_PARASOL_LICHEN = 0
FOB_PRUNE_MOREL_MUSHROOM = 0
FOB_STINKHORN = 0
FOB_VIOLET_COPRINUS = 0
FOB_WHITE_CAP = 0
FOB_DAMAGED = 0
FOB_WARN_BROKEN = 0
FOB_RETICLE = 0
FOB_SEBASTIAN_BRUTYA = 0
FOB_MAZZA_MIRRI = 0
FOB_LADY_LLARELS_SHELTER = 0
FOB_BLACKHEART_HAVEN = 0
FOB_SHINYTRADE = 0
