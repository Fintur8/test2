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

Файл  <code>[docker-compose](https://github.com/Fintur8/test2/blob/main/docker-compose_v3_ubuntu_pgsql_local_2.yaml)</code>

	Не увидел как будет выглядеть конфиг zabbix_agent в таком случае. И где могу найти файлы проекта, чтобы мог запустить сам?

Конфиг можно глянуть тут: 
https://github.com/Fintur8/test2/blob/main/zabbix_agentd.conf

Файлы проекта я брал тут: 
git clone https://github.com/zabbix/zabbix-docker.git

Внес корректировки тут :
 vi ./env_vars/.POSTGRES_USER
 vi ./env_vars/.POSTGRES_PASSWORD

Остальное не трогал.	
	
</details> 
	
## Задача 2
	
<details><summary>Раскрой меня</summary>
  	
Потеряли все пароли, но Jenkins хранит в себе их. Как их восстановить?
  
</details> 
	
<details><summary>Ответ</summary>
	
Если я правильно понял, то можно воспользоваться https://scriptcrunch.com/groovy-script-retrieve-jenkins-credentials/

</details> 
	
## Задача 3
	
<details><summary>Раскрой меня</summary>
  
На сервере остался docker образ, но удалили Dockerfile.  
Как можно восстановить Dockerfile имея только Docker образ?  
  
</details> 
	
<details><summary>Ответ</summary>
	
Можно воспользоваться вот этим способом https://github.com/cucker0/DockerImage2Df  

	Что делает этот скрипт? Как это сделать без подобных скриптов, пользуясь командной строкой? 
	Нужен навык чтения чужих скриптов, а так же понимать как это работает.

Этот скрипт позволяет автоматически сгенерировать dockerfile из docker image с использованием  api докера,  sdk и скрипта питона. 

Можно также воспользоваться командой:
docker history example1 --no-trunc > test.txt
	


</details> 

## Задача 4
	
<details><summary>Раскрой меня</summary>
  
Создать pipeline в Jenkins, в котором есть dropdown выбора среды PROD/STAGE/DEV и еще один dropdown, который получает с Nexus список образов. 
При запуске, вывести в консоль, что было выбрано.  
  
</details> 
	
<details><summary>Ответ</summary>
  	
Установил Jenkins и развернул nexus в контейнере. 

![nexus1](https://user-images.githubusercontent.com/72273619/184480212-986faea7-5e35-4494-9a4d-26e4fdb202b0.JPG)
![nexus](https://user-images.githubusercontent.com/72273619/184480221-39b7e150-9a80-4fd9-b78c-381706f992b1.JPG)
	
Нашел вот такой проект https://github.com/DeekshithSN/Jenkins (https://www.youtube.com/watch?v=G8wVM5irp0k) и все получилось. 

Для получения информации из репозитория nexus используются скрипты <code>[images.sh](https://github.com/Fintur8/test2/blob/main/images.sh)
</code> и <code>[repo.sh](https://github.com/Fintur8/test2/blob/main/repo.sh)</code>

в pipeline использовался Active Choices Parameter и Active Choices Reactive Parameter c указанием зависимого Referenced parameters


для отображения repo list: 

	def proc ='/opt/repo.sh'.execute()
	proc.waitFor()       

	def output = proc.in.text
	def exitcode= proc.exitValue()
	def error = proc.err.text

	if (error) {
	    println "Std Err: ${error}"
	    println "Process exit code: ${exitcode}"
	    return exitcode
	}
	return output.tokenize()


для отображения images list: 

	def proc ="/opt/images.sh ${repo}".execute()
	proc.waitFor()       

	def output = proc.in.text
	def exitcode= proc.exitValue()
	def error = proc.err.text

	if (error) {
	    println "Std Err: ${error}"
	    println "Process exit code: ${exitcode}"
	    return exitcode
	}
	return output.tokenize()


В pipeline вставил скрипт для вывода выбраных параметров в консоль: 

	pipeline {
	    agent any
	    stages {
		stage('Test') {
		    steps {
			echo "Выбранный репозиторий ${params.repo}"

			echo "Выбранный образ: ${params.images}"

			echo "Целевая среда: ${params.CHOICE}"

			 }
		}
	    }
	}

![готовый пайп](https://user-images.githubusercontent.com/72273619/184480189-e4c82fcc-1d65-47ed-80dc-e530b3c2eaf0.JPG)

  
</details> 
