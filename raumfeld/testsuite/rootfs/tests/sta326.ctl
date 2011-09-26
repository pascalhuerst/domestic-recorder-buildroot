state.DDX {
	control.1 {
		iface MIXER
		name 'Master Volume'
		value 199
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 255'
			dbmin -9999999
			dbmax 50
			dbvalue.0 -2750
		}
	}
	control.2 {
		iface MIXER
		name 'Master Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.3 {
		iface MIXER
		name 'Ch1 Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.4 {
		iface MIXER
		name 'Ch2 Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.5 {
		iface MIXER
		name 'Ch3 Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.6 {
		iface MIXER
		name 'Ch1 Volume'
		value 180
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 255'
			dbmin -9999999
			dbmax 4800
			dbvalue.0 1050
		}
	}
	control.7 {
		iface MIXER
		name 'Ch2 Volume'
		value 180
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 255'
			dbmin -9999999
			dbmax 4800
			dbvalue.0 1050
		}
	}
	control.8 {
		iface MIXER
		name 'Ch3 Volume'
		value 192
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 255'
			dbmin -9999999
			dbmax 4800
			dbvalue.0 1650
		}
	}
	control.9 {
		iface MIXER
		name 'De-emphasis Filter Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.10 {
		iface MIXER
		name 'Compressor/Limiter Switch'
		value Anti-Clipping
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 Anti-Clipping
			item.1 'Dynamic Range Compression'
		}
	}
	control.11 {
		iface MIXER
		name 'Miami Mode Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.12 {
		iface MIXER
		name 'Zero Cross Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.13 {
		iface MIXER
		name 'Soft Ramp Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.14 {
		iface MIXER
		name 'Auto-Mute Switch'
		value true
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.15 {
		iface MIXER
		name 'Automode EQ'
		value User
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 User
			item.1 Preset
			item.2 Loudness
		}
	}
	control.16 {
		iface MIXER
		name 'Automode GC'
		value User
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 User
			item.1 'AC no clipping'
			item.2 'AC limited clipping (10%)'
			item.3 'DRC nighttime listening mode'
		}
	}
	control.17 {
		iface MIXER
		name 'Automode XO'
		value User
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 User
			item.1 '80Hz'
			item.2 '100Hz'
			item.3 '120Hz'
			item.4 '140Hz'
			item.5 '160Hz'
			item.6 '180Hz'
			item.7 '200Hz'
			item.8 '220Hz'
			item.9 '240Hz'
			item.10 '260Hz'
			item.11 '280Hz'
			item.12 '300Hz'
			item.13 '320Hz'
			item.14 '340Hz'
			item.15 '360Hz'
		}
	}
	control.18 {
		iface MIXER
		name 'Preset EQ'
		value Flat
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 Flat
			item.1 Rock
			item.2 'Soft Rock'
			item.3 Jazz
			item.4 Classical
			item.5 Dance
			item.6 Pop
			item.7 Soft
			item.8 Hard
			item.9 Party
			item.10 Vocal
			item.11 Hip-Hop
			item.12 Dialog
			item.13 'Bass-boost #1'
			item.14 'Bass-boost #2'
			item.15 'Bass-boost #3'
			item.16 'Loudness 1'
			item.17 'Loudness 2'
			item.18 'Loudness 3'
			item.19 'Loudness 4'
			item.20 'Loudness 5'
			item.21 'Loudness 6'
			item.22 'Loudness 7'
			item.23 'Loudness 8'
			item.24 'Loudness 9'
			item.25 'Loudness 10'
			item.26 'Loudness 11'
			item.27 'Loudness 12'
			item.28 'Loudness 13'
			item.29 'Loudness 14'
			item.30 'Loudness 15'
			item.31 'Loudness 16'
		}
	}
	control.19 {
		iface MIXER
		name 'Ch1 Tone Control Bypass Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.20 {
		iface MIXER
		name 'Ch2 Tone Control Bypass Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.21 {
		iface MIXER
		name 'Ch1 EQ Bypass Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.22 {
		iface MIXER
		name 'Ch2 EQ Bypass Switch'
		value false
		comment {
			access 'read write'
			type BOOLEAN
			count 1
		}
	}
	control.23 {
		iface MIXER
		name 'Ch1 Master Volume Bypass Switch'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 1'
		}
	}
	control.24 {
		iface MIXER
		name 'Ch2 Master Volume Bypass Switch'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 1'
		}
	}
	control.25 {
		iface MIXER
		name 'Ch3 Master Volume Bypass Switch'
		value 0
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 1'
		}
	}
	control.26 {
		iface MIXER
		name 'Ch1 Limiter Select'
		value 'Limiter Disabled'
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 'Limiter Disabled'
			item.1 'Limiter #1'
			item.2 'Limiter #2'
		}
	}
	control.27 {
		iface MIXER
		name 'Ch2 Limiter Select'
		value 'Limiter Disabled'
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 'Limiter Disabled'
			item.1 'Limiter #1'
			item.2 'Limiter #2'
		}
	}
	control.28 {
		iface MIXER
		name 'Ch3 Limiter Select'
		value 'Limiter Disabled'
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 'Limiter Disabled'
			item.1 'Limiter #1'
			item.2 'Limiter #2'
		}
	}
	control.29 {
		iface MIXER
		name 'Bass Tone Control'
		value 7
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 15'
			dbmin -120
			dbmax 2880
			dbvalue.0 1280
		}
	}
	control.30 {
		iface MIXER
		name 'Treble Tone Control'
		value 7
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 15'
			dbmin -120
			dbmax 2880
			dbvalue.0 1280
		}
	}
	control.31 {
		iface MIXER
		name 'Limiter1 Attack Rate (dB/ms)'
		value '0.0902'
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 '3.1584'
			item.1 '2.7072'
			item.2 '2.2560'
			item.3 '1.8048'
			item.4 '1.3536'
			item.5 '0.9024'
			item.6 '0.4512'
			item.7 '0.2256'
			item.8 '0.1504'
			item.9 '0.1123'
			item.10 '0.0902'
			item.11 '0.0752'
			item.12 '0.0645'
			item.13 '0.0564'
			item.14 '0.0501'
			item.15 '0.0451'
		}
	}
	control.32 {
		iface MIXER
		name 'Limiter2 Attack Rate (dB/ms)'
		value '0.0902'
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 '3.1584'
			item.1 '2.7072'
			item.2 '2.2560'
			item.3 '1.8048'
			item.4 '1.3536'
			item.5 '0.9024'
			item.6 '0.4512'
			item.7 '0.2256'
			item.8 '0.1504'
			item.9 '0.1123'
			item.10 '0.0902'
			item.11 '0.0752'
			item.12 '0.0645'
			item.13 '0.0564'
			item.14 '0.0501'
			item.15 '0.0451'
		}
	}
	control.33 {
		iface MIXER
		name 'Limiter1 Release Rate (dB/ms)'
		value '0.0264'
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 '0.5116'
			item.1 '0.1370'
			item.2 '0.0744'
			item.3 '0.0499'
			item.4 '0.0360'
			item.5 '0.0299'
			item.6 '0.0264'
			item.7 '0.0208'
			item.8 '0.0198'
			item.9 '0.0172'
			item.10 '0.0147'
			item.11 '0.0137'
			item.12 '0.0134'
			item.13 '0.0117'
			item.14 '0.0110'
			item.15 '0.0104'
		}
	}
	control.34 {
		iface MIXER
		name 'Limiter2 Release Rate (dB/ms)'
		value '0.0264'
		comment {
			access 'read write'
			type ENUMERATED
			count 1
			item.0 '0.5116'
			item.1 '0.1370'
			item.2 '0.0744'
			item.3 '0.0499'
			item.4 '0.0360'
			item.5 '0.0299'
			item.6 '0.0264'
			item.7 '0.0208'
			item.8 '0.0198'
			item.9 '0.0172'
			item.10 '0.0147'
			item.11 '0.0137'
			item.12 '0.0134'
			item.13 '0.0117'
			item.14 '0.0110'
			item.15 '0.0104'
		}
	}
	control.35 {
		iface MIXER
		name 'Limiter1 Attack Threshold (AC Mode)'
		value 9
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
			dbmin -1200
			dbmax 1100
			dbvalue.0 400
		}
	}
	control.36 {
		iface MIXER
		name 'Limiter2 Attack Threshold (AC Mode)'
		value 9
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
			dbmin -1200
			dbmax 1100
			dbvalue.0 400
		}
	}
	control.37 {
		iface MIXER
		name 'Limiter1 Release Threshold (AC Mode)'
		value 6
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
			dbmin -9999999
			dbmax 100
			dbvalue.0 -800
		}
	}
	control.38 {
		iface MIXER
		name 'Limiter2 Release Threshold (AC Mode)'
		value 6
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
			dbmin -9999999
			dbmax 100
			dbvalue.0 -800
		}
	}
	control.39 {
		iface MIXER
		name 'Limiter1 Attack Threshold (DRC Mode)'
		value 9
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
			dbmin -3100
			dbmax -400
			dbvalue.0 -1500
		}
	}
	control.40 {
		iface MIXER
		name 'Limiter2 Attack Threshold (DRC Mode)'
		value 9
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
			dbmin -3100
			dbmax -400
			dbvalue.0 -1500
		}
	}
	control.41 {
		iface MIXER
		name 'Limiter1 Release Threshold (DRC Mode)'
		value 6
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
			dbmin -9999999
			dbmax -600
			dbvalue.0 -2800
		}
	}
	control.42 {
		iface MIXER
		name 'Limiter2 Release Threshold (DRC Mode)'
		value 6
		comment {
			access 'read write'
			type INTEGER
			count 1
			range '0 - 16'
			dbmin -9999999
			dbmax -600
			dbvalue.0 -2800
		}
	}
	control.43 {
		iface MIXER
		name 'Ch1 - Biquad 1'
		value '000000000000000000000000400000'
		comment {
			access 'read write'
			type BYTES
			count 15
		}
	}
	control.44 {
		iface MIXER
		name 'Ch1 - Biquad 2'
		value '8031487fceb87fceae80627d3fe75c'
		comment {
			access 'read write'
			type BYTES
			count 15
		}
	}
	control.45 {
		iface MIXER
		name 'Ch1 - Biquad 3'
		value '000000000000000000000000400000'
		comment {
			access 'read write'
			type BYTES
			count 15
		}
	}
	control.46 {
		iface MIXER
		name 'Ch1 - Biquad 4'
		value '000000000000000000000000400000'
		comment {
			access 'read write'
			type BYTES
			count 15
		}
	}
	control.47 {
		iface MIXER
		name 'Ch2 - Biquad 1'
		value '000000000000000000000000400000'
		comment {
			access 'read write'
			type BYTES
			count 15
		}
	}
	control.48 {
		iface MIXER
		name 'Ch2 - Biquad 2'
		value '802d487fd2b87fd2b0805a7f3fe95c'
		comment {
			access 'read write'
			type BYTES
			count 15
		}
	}
	control.49 {
		iface MIXER
		name 'Ch2 - Biquad 3'
		value '000000000000000000000000400000'
		comment {
			access 'read write'
			type BYTES
			count 15
		}
	}
	control.50 {
		iface MIXER
		name 'Ch2 - Biquad 4'
		value '000000000000000000000000400000'
		comment {
			access 'read write'
			type BYTES
			count 15
		}
	}
	control.51 {
		iface MIXER
		name High-pass
		value '83cfb37c304d7c21c78782593e1826'
		comment {
			access 'read write'
			type BYTES
			count 15
		}
	}
	control.52 {
		iface MIXER
		name Low-pass
		value '0003210003217eefd88213c8000190'
		comment {
			access 'read write'
			type BYTES
			count 15
		}
	}
	control.53 {
		iface MIXER
		name 'Ch1 - Prescale'
		value '6624af'
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.54 {
		iface MIXER
		name 'Ch2 - Prescale'
		value '6624af'
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.55 {
		iface MIXER
		name 'Ch1 - Postscale'
		value '7fffff'
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.56 {
		iface MIXER
		name 'Ch2 - Postscale'
		value '7fffff'
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.57 {
		iface MIXER
		name 'Ch3 - Postscale'
		value '721482'
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.58 {
		iface MIXER
		name 'Thermal warning - Postscale'
		value '5a9df7'
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.59 {
		iface MIXER
		name 'Ch1 - Mix 1'
		value '7fffff'
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.60 {
		iface MIXER
		name 'Ch1 - Mix 2'
		value '000000'
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.61 {
		iface MIXER
		name 'Ch2 - Mix 1'
		value '000000'
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.62 {
		iface MIXER
		name 'Ch2 - Mix 2'
		value '7fffff'
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.63 {
		iface MIXER
		name 'Ch3 - Mix 1'
		value '400000'
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
	control.64 {
		iface MIXER
		name 'Ch3 - Mix 2'
		value '400000'
		comment {
			access 'read write'
			type BYTES
			count 3
		}
	}
}

