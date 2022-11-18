# kaniko-codebuild
Kaniko Dockerfile ready to enable CodeBuild secure builds without the need of privileged pipelines.
The resulting image will include the AWS CLI to fit perfectly within existing CodeBuild projects.
It is meant to be a followup stage in your build chain which allows to create Docker images without the need of giving access 
to a Docker daemon and therefore no need to set `PrivilegedMode: true` in your CodeBuild projects.

## Build
To build this image simply use `docker build -t TARGET_REPOSITORY_URL:kaniko-helper .` on your local machine. 
Then push (`docker push TARGET_REPOSITORY_URL:kaniko-helper`) the image to your desired target repository (e.g. ECR, etc.). If using AWS, I highly recommend using AWS ECR
being an onboard solution which integrates well permission-wise with AWS CodeBuild and makes life easier using custom images.

This is the only time you will need actual access to Docker.

## Use in CodeBuild
To use the newly created image in CodeBuild you need access to `TARGET_REPOSITORY_URL:kaniko-helper` and to setup the 
image in your CodeBuild project, like: 
```yaml
DockerBuildProject:
    Type: AWS::CodeBuild::Project
    Condition: UseSecureDockerBuild
    Properties:
      Name: myproject
    ...
      Environment:
        Type: LINUX_CONTAINER
        ComputeType: BUILD_GENERAL1_SMALL
        Image: TARGET_REPOSITORY_URL:kaniko-helper
        PrivilegedMode: false # (!) Disable those privileges ;)
    ...
    Source:
        BuildSpec: builspec.yaml 
```

Instead of setting the BuildSpec via Source, you can also use the CodeBuild buildspec editor ofc.

For more details check out the provided [./buildspec.yml](./buildspec.yml). 

# Customize
You are not limited to use the AWS CLI official base image to form the foundation of this Kaniko helper. You are free to use whatever works for you.
For that purpose, simply adjust the [./Dockerfile](./Dockerfile) to your needs.

You may encounter issues with a symlink issue. To fix this problem add the following to your Dockerfile:

```bash
# Fix symlink issue
RUN rm /var/spool/mail
RUN mkdir /var/spool/mail
```