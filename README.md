#Knative Take Home Test
I chose the second option to create a knative hello-world application. 

##Local Deployment Requirements
You will need the following to build and deploy locally:
1. Helm (v.3)
2. Maven/Java JDK 21.
3. A knative-enabled kubernetes cluster (I used minikube/kn quickstart)
4. Docker runtime
5. Be able to run .sh scripts


##App summary
- Used `kn func` to create a spring-boot app. I added a `RestController` class and unit test.
- knative service yaml file to control a serverless deployment of the app, setting rollout-strategy and resource limits.
- helm-deployment chart and config to create a kubernetes deployment/service; configures the deployment to have 2-4 replicas
- "CI/CD" script that will build/test/tag/deploy the application. Will deploy serverless w/ knative or "microservice" w/ helm

##Build/Deploy Script
Run `chmod +x ci-cd.sh` in the `springboot-tes` directory. Runthe script and select from the following options:
```
1. Just build; runs maven and deploys the docker image"
2. Build and deploy, using knative"
3. Build and deploy with Helm"
4. Deploy the latest version with Knative"
5. Deploy the latest version with Helm"
```
