resource "aws_ecr_repository" "image_repository" {
  name = "ef-cms-us-east-1"
}

data "template_file" "repo_policy_file" {
    template = file("templates/ecr_policy.tpl.json")

  vars = {
    numberOfImages = 5
  }
}

# keep the last 10 images
resource "aws_ecr_lifecycle_policy" "repo_policy" {
  repository = aws_ecr_repository.image_repository.name
  policy = data.template_file.repo_policy_file.rendered
}
