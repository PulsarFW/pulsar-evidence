fx_version("cerulean")


name 'Pulsar Evidence'
description 'Forensics: DNA collection and ballistics/serial number matching'
author 'Artmines - maintained for Pulsar Framework'
url 'https://pulsarframe.work'
version 'v1.0.0'

version_check 'yes'
github 'https://github.com/PulsarFW/pulsar_evidence'
games({ "gta5" }) -- 'gta5' for GTAv / 'rdr3' for Red Dead 2, 'gta5','rdr3' for both
lua54("yes")
client_script("@pulsar_core/components/cl_error.lua")
shared_script("@pulsar_core/core/sh_pulsar.lua")
client_script("@pulsar_pwnzor/client/check.lua")
server_script("@oxmysql/lib/MySQL.lua")

description("Pulsar Framework Evidence System")
name("Pulsar Framework: pulsar_evidence")
author("Pulsar Team")
version("v1.0.0")
url("https://pulsarfw.com")

server_scripts({
	"shared/**/*.lua",
	"server/**/*.lua",
})

client_scripts({
	"shared/**/*.lua",
	"client/**/*.lua",
})
