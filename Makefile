.PHONY: deploy

deploy:
	terraform apply

id_rsa:
	ssh-keygen -t rsa -b 2048 -f $@ -P '' -C factorio

id_rsa.pub: id_rsa
