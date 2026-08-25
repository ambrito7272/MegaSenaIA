// NEODRIVE — paleta, métricas e escala tipográfica compartilhadas.
.pragma library

// Referência de design (escala proporcional = min(avW/designW, avH/designH))
var designWidth  = 796
var designHeight = 796

// Paleta base
var background   = "#0b0d11"
var panel        = "#14171d"
var panelBorder  = "#232833"
var trackColor   = "#262b35"
var tickMajor    = "#d7dbe2"
var tickMinor    = "#707684"
var labelColor   = "#c9ced8"
var titleColor   = "#8a90a0"
var valueColor   = "#f2f4f8"
var needleBody   = "#e6e9ee"
var needleBase   = "#9aa1ad"
var needleTip    = "#ff3b30"
var hubColor     = "#1a1e26"
var hubBorder    = "#39404e"

// Zonas de estado (só aparecem quando o estado real pedir)
var zoneWarning      = "#ffcf40"
var zoneCritical     = "#ff453a"
var zoneWarningAlpha = 0.55
var zoneCriticalAlpha= 0.65

// Vidro (glassmorphism discreto)
var glassFill   = Qt.rgba(0.09, 0.10, 0.14, 0.72)
var glassBorder = Qt.rgba(1.0, 1.0, 1.0, 0.14)

// Halo do arco de valor
var haloOpacity = 0.20

// Escala tipográfica (razões sobre o raio do gauge)
var titleRatio = 0.115
var valueRatio = 0.30
var unitRatio  = 0.105

// Combustível
var fuelOk      = "#ffd24a"
var fuelWarn    = "#ff9f2e"
var fuelDanger  = "#ff453a"

// Aliases de estado
var okColor     = "#41d17c"
var warnColor   = zoneWarning
var dangerColor = zoneCritical
