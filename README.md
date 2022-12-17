I'm working through the Amazon API Gateway [getting started][] guide,
translating the manual actions into terraform config, but otherwise not
changing anything yet.

Oh, actually there is also a Terraform [tutorial][] for the exact same setup. I
am starting to revise my previous work in light of that now.

So far I have completed step one.

Once I finish, next steps look like:
- Put [terraform state][] in an S3 bucket.
- Switch to go.
- Add TLS.
- Add custom domain.
- Add auth.

[getting started]: https://docs.aws.amazon.com/apigateway/latest/developerguide/getting-started.html#getting-started-create-function
[tutorial]: https://developer.hashicorp.com/terraform/tutorials/aws/lambda-api-gateway
[terraform state]: https://www.alexhyett.com/terraform-s3-static-website-hosting/
