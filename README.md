<p align="center">
  <img src="https://github.com/ehemmerlin/aws-ec2-k3d/raw/main/images/logo.jpg" width="882" alt="Kubernetes in Docker on AWS EC2">
  <p align="center">
    <strong>For full documentation, visit <a href="https://medium.com/@erichemmerlin/kubernetes-in-docker-on-aws-ec2-1c7fb7625951">this Medium post</a>.</strong>
  </p>
</p>

# Kubernetes in Docker on AWS EC2
Using AWS CLI we'll provision an EC2 Linux machine pre-installed with git, docker, docker compose and k3d in order to launch a Kubernetes cluster in Docker.

## Prerequisite
- Working on a Linux machine or a Mac
- Having an AWS account (create one [here](https://portal.aws.amazon.com/billing/signup#/start)) or an AWS Educate account
- Willing to learn some new things

## AWS CLI
To install the latest version of the AWS CLI, use the following command block:
```
> curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

## AWS Credentials
### AWS account
For general use, the aws configure command is the fastest way to set up your AWS CLI installation. When you enter this command, the AWS CLI prompts you for four pieces of information:
```
> aws configure
AWS Access Key ID [None]: ***********************************************
AWS Secret Access Key [None]: *******************************************
Default region name [None]: us-west-2
Default output format [None]: json
```

See [AWS CLI configure quickstart](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html) for more information about how to find these AWS Access and Secret Access keys.

### AWS Educate account
If you have an AWS Educate account, go to AWS Educate portal: https://www.awseducate.com/signin/SiteLogin

Navigate to your classroom and click on **Account Details** then click on **AWS CLI Show**.

On a Linux machine copy and paste AWS CLI credentials from previous step.
```
> nano ~/.aws/credentials
[default]
region=us-east-1
aws_access_key_id=***********************************************
aws_secret_access_key=*******************************************
aws_session_token=***********************************************
```

Optional : if you want to use a different profile instead of the default one, then update the credentials file with this new profile name (for example awseducate) and set AWS_PROFILE before you continue, like shown bellow.
```
> more ~/.aws/credentials
[awseducate]
region=us-east-1
aws_access_key_id=***********************************************
aws_secret_access_key=*******************************************
aws_session_token=***********************************************
> export AWS_PROFILE=awseducate
```

## Create EC2

First of all, clone this repository: https://github.com/ehemmerlin/aws-educate-k3d.
```
> git clone https://github.com/ehemmerlin/aws-ec2-k3d
> cd aws-ec2-k3d
```

*Note: the following script starts a t2.small EC2 Linux machine. This EC2 type is not part of the AWS free tier, you will be charged for it. In order to launch a t2.micro which is part of the AWS free tier, type "script/up.sh micro" instead of the "script/up.sh" command, but bear in mind that you'll not be able to launch the full Kubernetes example below, because of the lack of ressources of the t2.micro machine.*

Lets create an EC2 Linux machine using cloudformation. In your terminal type this command:
```
> script/up.sh
Waiting for changeset to be created..
Waiting for stack create/update to complete
Successfully created/updated stack - EC2-K3D
Successufly created the EC2 stack and tke key pair 🎉

Type the following command to login to EC2:
ssh -i tmp/key.pem ec2-user@ec2-xx-xx-xx-xx.compute-1.amazonaws.com
```

## Launch K3D
It's time to enter into the magic world of Kubernetes. In your terminal type the following commands:
```
> ssh -i tmp/key.pem ec2-user@ec2-xx-xx-xx-xx.compute-1.amazonaws.com
The authenticity of host 'ec2-xx-xx-xx-xx.compute-1.amazonaws.com (xx.xx.xx.xx)' can't be established.
ECDSA key fingerprint is SHA256:************.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'ec2-xx-xx-xx-xx.compute-1.amazonaws.com,xx.xx.xx.xx' (ECDSA) to the list of known hosts.

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
[ec2-user@ip-xx-xx-xx-xx ~]$ k3d cluster create k3s --api-port 6550 -p "8080:80@loadbalancer" --agents 2
[ec2-user@ip-xx-xx-xx-xx ~]$ kubectl create deployment nginx --image=nginx
[ec2-user@ip-xx-xx-xx-xx ~]$ kubectl create service clusterip nginx --tcp=80:80
[ec2-user@ip-xx-xx-xx-xx ~]$ nano ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx
  annotations:
    ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx
            port:
              number: 80
[ec2-user@ip-xx-xx-xx-xx ~]$ kubectl apply -f ingress.yaml
[ec2-user@ip-xx-xx-xx-xx ~]$ curl localhost:8081
```
At this step Nginx's welcome page should appear as an html page.

Open a browser and navigate to:
http://ec2-xx-xx-xx-xx.compute-1.amazonaws.com:8080

Your Nginx is welcoming you from your browser, congratulations!

Let's play with Kubernetes by creating different ressources. The ports 80, 8000 and 8080 are opened.

## Delete K3D
Type these commands to delete the k3d cluster:
```
[ec2-user@ip-xx-xx-xx-xx ~]$ k3d cluster delete k3s
[ec2-user@ip-xx-xx-xx-xx ~]$ exit
```

## Remove EC2
To get rid of everything we created so far, type:
```
> script/down.sh
Successufly removed the EC2 stack and the key pair 🎉
```

## Further readings
- To spin up a production ready cluster: [GitLab Auto DevOps on DigitalOcean Kubernetes cluster](https://erichemmerlin.medium.com/gitlab-auto-devops-on-digitalocean-kubernetes-cluster-f8b744b1e64c)
- To learn more about Kubernetes: [Kubernetes - CKAD preparation](https://erichemmerlin.medium.com/kubernetes-ckad-preparation-65a5fffe6b9a)

## Credits
- https://github.com/wongcyrus/managed-aws-educate-classroom
- [Image created by vectorpouch - www.freepik.com](https://www.freepik.com/vectors/travel)