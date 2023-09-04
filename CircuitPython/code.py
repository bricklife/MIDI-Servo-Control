import board

import usb_midi
import adafruit_midi
from adafruit_midi.pitch_bend import PitchBend

import pwmio
from adafruit_motor import servo

midi = adafruit_midi.MIDI(midi_in=usb_midi.ports[0], midi_out=usb_midi.ports[1], debug=True)

pins = [board.GP15, board.GP16] # Raspberry Pi Pico

servos = []
for pin in pins:
    pwm = pwmio.PWMOut(pin, frequency=50)
    servos.append(servo.Servo(pwm, actuation_range=180, min_pulse=500, max_pulse=2500)) # FT90B

while True:
    msg = midi.receive()
    if isinstance(msg, PitchBend):
        if msg.channel < len(servos) and msg.pitch_bend <= servos[msg.channel].actuation_range:
            servos[msg.channel].angle = msg.pitch_bend
