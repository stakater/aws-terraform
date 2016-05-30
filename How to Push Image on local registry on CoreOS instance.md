# Step 1: Clone Repository

Clone your application repository which contains the DockerFile
```
git clone '<yourRepositoryURL>'
```

# Step 2: Pull Registry

Pull docker registry from dockerHub

```
docker pull registry
```

# Step 3: Run docker registry image 

```
docker run -p 5000:5000 -d --name=basic_registry registry
```
-p flag stands for PORT,we are exposing port 5000 on from the container onto host port 5000. The -d flag stands for daemon, this will cause the container to run in the background

# Step 4: Run Docker Container

```
sudo docker run -d --name container_name -v path_to_map_outside_docker_container:path_to_map_inside_docker_container docker_image_to_be_pulled_inside_this_container
```

e.g.

`sudo docker run -d --name docker_grails -v /home/app:/app ahmadiq/grails:2.2.4`

# Step 5: Copying inside docker container 

Copy application directory inside docker container which we created above.

```
sudo docker cp application_directory docker_container:folder_inside_container
```
e.g.

`sudo docker cp ./ docker_grails:/app`

# Step 6: Executing Commands inside docker container

```
sudo docker exec docker_container /bin/bash 
```
Before executing compilation step we need to navigate to application directory using
  cd app_directory_name
Then we can execute compilation, build step and create war file 
e.g.

`grails refresh-dependencies clean compile`
'grails dev war'

# Step 7: Copying War File outside the container to application directory
```
sudo docker cp container_name:war_file_path_inside_container path_to_copy_war_file_outside_container
```
e.g. 
`sudo docker cp docker_grails:/app/app.war ./app_directory/`

After this stop and remove docker container 
'sudo docker stop docker_grails'
'sudo docker rm docker_grails'

# Step 8: Build Docker Image 

```
sudo docker build -t image_name/application_name:tag -f path_to_docker_file
```
e.g
`sudo docker build -t localhost:5000/app:latest -f /app_directory`

# Step 9: Push Docker Image 

```
sudo docker push  image_name/application_name:tag 
```
e.g
`sudo docker push localhost:5000/app:latest`
