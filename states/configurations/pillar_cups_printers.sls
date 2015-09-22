#!py

########################################################################
#NOTE: this is what the below represents.
#
#include:
#  - packages.cups
#
#/etc/cups/ppd/{{filename}}:
#  file.managed:
#    - source: {{source}}
#
#
#/etc/cups/printers.conf:
#  file:
#    - append
#    - sources: 
#      - {{source}}
#
########################################################################

def run():
	state = {}

        state['include'] = ['packages.cups']


	hostname = __grains__['host'].split('.')[0]

	printers = __salt__['pillar.get']('cups_printers', {})

	for group in __salt__['pillar.get']('machines:'+hostname+':groups', []):
		for (printer, printer_data) in __salt__['pillar.get']('machine_groups:'+group+':cups_printers', {}).items():
			printers[printer] = printer_data

	for (printer, printer_data) in __salt__['pillar.get']('machines:'+hostname+':cups_printers', {}).items():
		printers[printer] = printer_data



	sources = []

	for (printer, printer_data) in printers.items():
		if "printer" and "ppd" not in printer_data:
			continue

		ppd_path = printer_data['ppd']
		ppd_filename = ppd_path.rsplit('/', 1)
		ppd_filename = ppd_filename[len(ppd_filename)-1]

		state['/etc/cups/ppd/' + ppd_filename] = {
			'file.managed': [
				{'source': ppd_path},
			],
		}

		sources.append(printer_data['printer'])


	if sources:
		state['/etc/cups/printers.conf'] = {
			'file.append': [
				{'sources': sources},
			],
		}

	return state


