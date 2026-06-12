extends Node

var message_array : int = 0


var npc_dialogues = {
	# NPC_ID: Array of dialogue lines
	"default":[
		"If this dialogue is showing up, something went wrong. Take a screenshot and contact the developer."
	],
	"victim" :["lol. i'm in danger"],
	
	"DEV_TALK":["Hello! Welcome to the test build of Cruelty City.",
	"This area is made for your to try out the base structure of the game.",
	"Controls are on the bottom right of your screen, you can acess the stock market by pressing TAB",
	"And pressing 'M' twice makes you go back to the menu.",
	"If you find any bugs, make sure to report them on the game page.",
	"Have fun."],
	
	"initial_hello": ["Wake up sheeple. Dragged you out to the boat to here, you were in a deep sleep, twin.",
	"Left the essentials for your survival on this island next to your briefcase, make good usage of those.",
	"Remember, money is key around here, even if the island does not look too affected by extreme consumism.",
	"Also, i've stablished your contract with clear optics, so if you die you can ask for a body reconstruction for a small fee."],

	"phone_boot": [
		"Looking to make some hard cash I see? Well I have a job for you.",
		"Someone needs to be liquidated. 
		I've wired their location to you. 
		Deal with them, and I will ensure you are compesated handsomely.",
		"Good luck."
	],
	"jokapho_intro": [
		"You passed the death corridor.",
		"Most people don't.",
		"I'm Joka Photon. This is my facility.",
		"Officially, we research interdimensional travel.",
		"Unofficially, we look for something that survives the crossing.",
		"Every subject so far has failed. Some instantly. Some slowly.",
		"No one volunteers anymore.",
		"That's why the barrier exists.",
		"If you're standing here, it means you're usable.",
		"The machine behind me opens something I can't observe from this side.",
		"I don't know what's inside.",
		"I know what comes back. Usually nothing.",
		"Enter the portal.",
		"If you return, you'll be compensated.",
		"If you don't, the data is still valuable."],
	"trigon_thanks": [
		"THANK YOU, MOTHER SISTER."],
	"trigon_1_bless": ["I bestow  upon you power."],
	"trigon_2_bless": ["I bestow  upon you financial freedom."],
	"trigon_3_bless": ["I bestow  upon you metabolism."],
	"bion_default": ["YAY!"]

}

func get_dialog(diag_index : String)->Array:
	if npc_dialogues.has(diag_index):
		return npc_dialogues[diag_index]
	else:
		return npc_dialogues["default"]
