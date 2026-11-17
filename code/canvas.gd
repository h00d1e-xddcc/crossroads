extends CanvasLayer
class_name crossroads_canvas

@export var stats : Label 
@export var weapon : TextureRect
@export var bullets : Label
@export var hslider : HSlider
@export var escape : Panel
@export var slots : Array[crossroads_ui_inventory_button]
@export var buttons : Array[crossroads_button]

func load_classic() :
	stats = $ui_classic/stats
	weapon = $ui_classic/weapon
	hslider = $ui_classic/hp
	bullets = $ui_classic/bullets
	escape = $ui_classic/pause

	#arc.canvas.slots_input_redraw()
	arc.canvas.weapon.texture.region = arc.get_texture("")
	arc.canvas.bullets.text = ""
	arc.canvas.escape.visible = false
	arc.decals.resize(arc.settings.data["decal"])
	for i in buttons.size() :
		buttons[i].redraw()

func escape_redraw() :
	if escape.visible :
		escape.visible = false
	else : 
		escape.visible = true
func redraw() :
	stats.text = str(arc.user.points)
	slots_redraw()
	weapon_relabel(arc.user.item)
	if arc.user.item != null : weapon_redraw(arc.user.item.rect)
	else : weapon_redraw(arc.get_texture(""))

func slots_redraw(value : int = -1) :
	if arc.is_classic : return
	#print(arc.user.inventory[0])
	match value :
		0,1,2,3,4,5 :
			if arc.user.inventory[value] == null : arc.canvas.slots[value].clear()
			else : arc.canvas.slots[value].texture.texture.region = arc.user.inventory[value].rect

		_ :
			for i in slots.size() :
				if arc.user.inventory[i] == null : arc.canvas.slots[i].clear()
				else : arc.canvas.slots[i].texture.texture.region = arc.user.inventory[i].rect

func slots_input_redraw() :
	slots[0].input.text = "1"
	slots[1].input.text = "2"
	slots[2].input.text = "3"
	slots[3].input.text = "4"
	slots[5].input.text = "e"
	slots[4].input.text = "q"

func weapon_redraw(rect : Rect2i) :
	weapon.texture.region = rect

func weapon_relabel(item : crossroads_item) :
	if item != null : 
		var bullets_current = item.nbt.get("bullets", null)
		if bullets_current != null :
			bullets.text = str(bullets_current) + "/" + str(item.nbt["mbullets"])
		else : bullets.text = ""
	else : bullets.text = ""

func pts_calculate(value : int = 0, operator = "-") :
	#print(value)
	if value == 0 : stats.text = str(arc.user.points)
	else : stats.text = str(arc.user.points) + " " + operator + " " + str(value)
