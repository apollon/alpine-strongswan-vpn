.PHONY: build export clean run stop

CURR_DIR = $(shell pwd)

build:
	docker build --squash -t vpn .

export:
	docker save -o vpn.tar vpn

clean: 
	docker system prune -f

run: stop
	docker run -it --cap-add=NET_ADMIN --name=vpn \
		-p 500:500/udp -p 4500:4500/udp \
		-v $(CURR_DIR)/config/strongswan.conf:/etc/strongswan.conf \
		-v $(CURR_DIR)/config/ipsec.conf:/etc/ipsec.conf \
		-v $(CURR_DIR)/config/ipsec.secrets:/etc/ipsec.secrets \
		-v $(CURR_DIR)/config/ipsec.d:/etc/ipsec.d \
		vpn

stop:
	-docker stop vpn
	-docker rm vpn
