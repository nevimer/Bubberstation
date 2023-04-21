#define STUNNED "stunned"
#define WEAKEN "weakened"
#define PARALYSIS "paralysis"
#define SLEEPING "sleeping"
#define CONFUSED "confused"
#define STUNNED_STATUS (1<<0)
#define WEAKEN_STATUS (1<<1)
#define PARALYSIS_STATUS (1<<2)
#define SLEEPING_STATUS (1<<3)
#define CONFUSED_STATUS (1<<4)
#define PLANE_STATUS_INDICATOR -12 //Status Indicators that show over mobs' heads when certain things like stuns affect them.
#define STATUS_LAYER -2.1
#define STATUS_INDICATOR_Y_OFFSET 2 // Offset from the edge of the icon sprite, so 32 pixels plus whatever number is here.
#define STATUS_INDICATOR_ICON_X_SIZE 0 // Don't need to care about the Y size due to the origin being on the bottom side.
#define STATUS_INDICATOR_ICON_MARGIN 0 // The space between two status indicators. We don't do this with the current icons.
#define DEFAULT_MOB_SCALE 1
