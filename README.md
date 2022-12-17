I'm working through the Amazon API Gateway [getting started][] guide,
translating the manual actions into terraform config, but otherwise not
changing anything yet.

Oh, actually there is also a Terraform [tutorial][] for the exact same setup. I
am starting to revise my previous work in light of that now.

And I have just discovered [serverless.tf][], which might now be better suited
to do this work for me? Reading it, however, it seems to be a little more magic
and a little less orthogonal components than will help me learn and feel
empowered here. So I think I'll read and learn from it but not use it.

Once I finish, next steps look like:
- Put [terraform state][] in an S3 bucket.
- Switch to go.
- Add TLS.
- Add custom domain.
- Add auth.
- Explore using lambda [function aliases][] for rolling out new code.

[getting started]: https://docs.aws.amazon.com/apigateway/latest/developerguide/getting-started.html#getting-started-create-function
[tutorial]: https://developer.hashicorp.com/terraform/tutorials/aws/lambda-api-gateway
[serverless.tf]: https://serverless.tf
[terraform state]: https://www.alexhyett.com/terraform-s3-static-website-hosting/
[function aliases]: https://github.com/antonbabenko/serverless.tf#controlled-deployments-rolling-canary-rollbacks
