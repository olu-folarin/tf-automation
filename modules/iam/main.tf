variable "user_name" {
  type = string
}

resource "aws_iam_user" "this" {
  name = var.user_name
  path = "/cicd/"
}

resource "aws_iam_access_key" "this" {
  user = aws_iam_user.this.name
}

resource "aws_iam_user_policy_attachment" "ecr_full_access" {
  user       = aws_iam_user.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}
