<details><summary>Задачи</summary>

## Задача 1
	
<details><summary>Раскрой меня</summary>
	
Необходимо развернуть Zabbix мониторинг в компании на одном сервере изспользуя Docker.  
Отдельные контейнеры:  
БД Postgres,  
фронт-энд nginx,  
сервер zabbix  
При этом агент мониторинга zabbix этом сервере, должен быть установлен на сервере локально, не в контейнере и передавать данные на сервер zabbix.   
После перезапуска стека, все настройки должны сохрнятся. Адреса контейнеров статические.  
Решение должно быть оформлено в виде docker-compose  

</details> 
	
<details><summary>Ответ</summary>
	
		version: '3.5'

		services:
		 zabbix-build-base:
		  build:
		   context: ./Dockerfiles/build-base/ubuntu
		   cache_from:
		    - ubuntu:focal
		  image: zabbix-build-base:ubuntu-local

		 zabbix-build-pgsql:
		  build:
		   context: ./Dockerfiles/build-pgsql/ubuntu
		   cache_from:
		    - ubuntu:focal
		   args:
		    BUILD_BASE_IMAGE: zabbix-build-base:ubuntu-local
		  image: zabbix-build-pgsql:ubuntu-local
		  depends_on:
		   - zabbix-build-base

		 zabbix-server:
		  build:
		   context: ./Dockerfiles/server-pgsql/ubuntu
		   cache_from:
		    - ubuntu:focal
		   args:
		    BUILD_BASE_IMAGE: zabbix-build-pgsql:ubuntu-local
		  image: zabbix-server-pgsql:ubuntu-local
		  ports:
		   - "10051:10051"
		  volumes:
		   - /etc/localtime:/etc/localtime:ro
		   - ./zbx_env/usr/lib/zabbix/alertscripts:/usr/lib/zabbix/alertscripts:ro
		   - ./zbx_env/usr/lib/zabbix/externalscripts:/usr/lib/zabbix/externalscripts:ro
		   - ./zbx_env/var/lib/zabbix/export:/var/lib/zabbix/export:rw
		   - ./zbx_env/var/lib/zabbix/modules:/var/lib/zabbix/modules:ro
		   - ./zbx_env/var/lib/zabbix/enc:/var/lib/zabbix/enc:ro
		   - ./zbx_env/var/lib/zabbix/ssh_keys:/var/lib/zabbix/ssh_keys:ro
		   - ./zbx_env/var/lib/zabbix/mibs:/var/lib/zabbix/mibs:ro
		   - snmptraps:/var/lib/zabbix/snmptraps:rw
		  ulimits:
		   nproc: 65535
		   nofile:
		    soft: 20000
		    hard: 40000
		  deploy:
		   resources:
		    limits:
		      cpus: '0.70'
		      memory: 1G
		    reservations:
		      cpus: '0.5'
		      memory: 512M
		  env_file:
		   - ./env_vars/.env_db_pgsql
		   - ./env_vars/.env_srv
		  secrets:
		   - POSTGRES_USER
		   - POSTGRES_PASSWORD
		  depends_on:
		   - postgres-server
		   - zabbix-build-pgsql
		  networks:
		   zbx_net_backend:
		     aliases:
		      - zabbix-server
		      - zabbix-server-pgsql
		      - zabbix-server-ubuntu-pgsql
		      - zabbix-server-pgsql-ubuntu
			ipv4_address: 172.16.239.3 
		   zbx_net_frontend:
		    ipv4_address: 172.16.238.2
		  stop_grace_period: 30s
		  sysctls:
		   - net.ipv4.ip_local_port_range=1024 65000
		   - net.ipv4.conf.all.accept_redirects=0
		   - net.ipv4.conf.all.secure_redirects=0
		   - net.ipv4.conf.all.send_redirects=0
		  labels:
		   com.zabbix.description: "Zabbix server with PostgreSQL database support"
		   com.zabbix.company: "Zabbix LLC"
		   com.zabbix.component: "zabbix-server"
		   com.zabbix.dbtype: "pgsql"
		   com.zabbix.os: "ubuntu"


		 zabbix-web-nginx-pgsql:
		  build:
		   context: ./Dockerfiles/web-nginx-pgsql/ubuntu
		   cache_from:
		    - ubuntu:focal
		   args:
		    BUILD_BASE_IMAGE: zabbix-build-pgsql:ubuntu-local
		  image: zabbix-web-nginx-pgsql:ubuntu-local
		  ports:
		   - "80:8080"
		   - "443:8443"
		  volumes:
		   - /etc/localtime:/etc/localtime:ro
		   - ./zbx_env/etc/ssl/nginx:/etc/ssl/nginx:ro
		   - ./zbx_env/usr/share/zabbix/modules/:/usr/share/zabbix/modules/:ro
		#   - ./env_vars/.ZBX_DB_CA_FILE:/run/secrets/root-ca.pem:ro
		#   - ./env_vars/.ZBX_DB_CERT_FILE:/run/secrets/client-cert.pem:ro
		#   - ./env_vars/.ZBX_DB_KEY_FILE:/run/secrets/client-key.pem:ro
		  deploy:
		   resources:
		    limits:
		      cpus: '0.70'
		      memory: 512M
		    reservations:
		      cpus: '0.5'
		      memory: 256M
		  env_file:
		   - ./env_vars/.env_db_pgsql
		   - ./env_vars/.env_web
		  secrets:
		   - POSTGRES_USER
		   - POSTGRES_PASSWORD
		  depends_on:
		   - postgres-server
		   - zabbix-server
		   - zabbix-build-pgsql
		  healthcheck:
		   test: ["CMD", "curl", "-f", "http://localhost:8080/"]
		   interval: 10s
		   timeout: 5s
		   retries: 3
		   start_period: 30s
		  networks:
		   zbx_net_backend:
		    aliases:
		     - zabbix-web-nginx-pgsql
		     - zabbix-web-nginx-ubuntu-pgsql
		     - zabbix-web-nginx-pgsql-ubuntu
			ipv4_address: 172.16.239.4
		   zbx_net_frontend:
			ipv4_address: 172.16.238.3
		  stop_grace_period: 10s
		  sysctls:
		   - net.core.somaxconn=65535
		  labels:
		   com.zabbix.description: "Zabbix frontend on Nginx web-server with PostgreSQL database support"
		   com.zabbix.company: "Zabbix LLC"
		   com.zabbix.component: "zabbix-frontend"
		   com.zabbix.webserver: "nginx"
		   com.zabbix.dbtype: "pgsql"
		   com.zabbix.os: "ubuntu"

		 postgres-server:
		  image: postgres:13-alpine
		  volumes:
		   - ./zbx_env/var/lib/postgresql/data:/var/lib/postgresql/data:rw
		   - ./env_vars/.ZBX_DB_CA_FILE:/run/secrets/root-ca.pem:ro
		   - ./env_vars/.ZBX_DB_CERT_FILE:/run/secrets/server-cert.pem:ro
		   - ./env_vars/.ZBX_DB_KEY_FILE:/run/secrets/server-key.pem:ro
		  env_file:
		   - ./env_vars/.env_db_pgsql
		  secrets:
		   - POSTGRES_USER
		   - POSTGRES_PASSWORD
		  stop_grace_period: 1m
		  networks:
		   zbx_net_backend:
		    aliases:
		     - postgres-server
		     - pgsql-server
		     - pgsql-database
			ipv4_address: 172.16.239.2
		 db_data_pgsql:
		  image: busybox
		  volumes:
		   - ./zbx_env/var/lib/postgresql/data:/var/lib/postgresql/data:rw


		networks:
		  zbx_net_frontend:
		    driver: bridge
		    driver_opts:
		      com.docker.network.enable_ipv6: "false"
		    ipam:
		      driver: default
		      config:
		      - subnet: 172.16.238.0/24
		  zbx_net_backend:
		    driver: bridge
		    driver_opts:
		      com.docker.network.enable_ipv6: "false"
		    internal: true
		    ipam:
		      driver: default
		      config:
		      - subnet: 172.16.239.0/24

		volumes:
		  snmptraps:

		secrets:
		  POSTGRES_USER:
		    file: ./env_vars/.POSTGRES_USER
		  POSTGRES_PASSWORD:
		    file: ./env_vars/.POSTGRES_PASSWORD

</details> 
	
## Задача 2
	
<details><summary>Раскрой меня</summary>
  	
Потеряли все пароли, но Jenkins хранит в себе их. Как их восстановить?
  
</details> 
	
<details><summary>Ответ</summary>
	


</details> 
	
## Задача 3
	
<details><summary>Раскрой меня</summary>
  
На сервере остался docker образ, но удалили Dockerfile.  
Как можно восстановить Dockerfile имея только Docker образ?  
  
</details> 
	
<details><summary>Ответ</summary>
	
Можно воспользоваться вот этим способом https://github.com/cucker0/DockerImage2Df  

</details> 

## Задача 4
	
<details><summary>Раскрой меня</summary>
  
Создать pipeline в Jenkins, в котором есть dropdown выбора среды PROD/STAGE/DEV и еще один dropdown, который получает с Nexus список образов. 
При запуске, вывести в консоль, что было выбрано.  
  
</details> 
	
<details><summary>Ответ</summary>
  	
Можно воспользоваться вот этим способом https://github.com/cucker0/DockerImage2Df  
  
</details> 
