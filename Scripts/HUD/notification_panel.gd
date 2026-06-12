extends Control
@onready var rich_text: RichTextLabel = $MarginContainer/ColorRect/VBoxContainer/RichTextLabel
@onready var clear_timer: Timer = $CLEAR_TIMER

# Track messages and timing
var message_queue: Array = []
var current_timer: Timer = null

func sub_text(text: String):
	# Add new message to the top (or bottom based on preference)
	# This adds to bottom (newest at bottom like Cruelty Squad)
	rich_text.append_text("> " + text + "\n")
	
	# Store the message in queue for removal tracking
	message_queue.append(text)
	
	# Reset timer
	if clear_timer.is_stopped():
		clear_timer.start()
	else:
		clear_timer.start()  # Restart timer

func _on_clear_timer_timeout() -> void:
	# Remove the LAST message (oldest or newest based on your preference)
	if message_queue.size() > 0:
		# Remove the oldest message (first one added)
		message_queue.pop_front()
		
		# Rebuild the entire text
		_rebuild_text()
	
	# If there are still messages, keep timer running
	if message_queue.size() > 0:
		clear_timer.start()
	else:
		# No messages left, timer will stop
		pass

func _rebuild_text():
	# Clear and rebuild all messages
	rich_text.clear()
	for msg in message_queue:
		rich_text.append_text("> " + msg + "\n")

# Alternative: Remove newest message first (like a stack)
func sub_text_newest_first(text: String):
	rich_text.append_text("> " + text + "\n")
	message_queue.append(text)
	
	if clear_timer.is_stopped():
		clear_timer.start()
	else:
		clear_timer.start()

func _on_clear_timer_timeout_newest_first() -> void:
	if message_queue.size() > 0:
		# Remove the newest message (last one added)
		message_queue.pop_back()
		_rebuild_text()
	
	if message_queue.size() > 0:
		clear_timer.start()

# Manual control functions
func clear_all_messages():
	message_queue.clear()
	rich_text.clear()
	if clear_timer.is_stopped() == false:
		clear_timer.stop()

func remove_last_message():
	if message_queue.size() > 0:
		message_queue.pop_back()
		_rebuild_text()

func remove_first_message():
	if message_queue.size() > 0:
		message_queue.pop_front()
		_rebuild_text()
