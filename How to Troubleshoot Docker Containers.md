  In order to view the list of running docker containers use:
  
    ```
      docker ps 
    ```
  To view the logs for specific container use:

    ```
      docker logs CONTAINER_NAME / CONTAINER_ID
    ```  
  To go inside of specific docker container use:

      ```
      sudo docker exec -it CONTAINER_NAME /bin/bash
      ```
  To view the log file inside specific docker container use above command and then navigate to following directory :

      ```
      /var/log/
      ```
  
