# Trust policy: the EC2 service is allowed to assume this role
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app" {
  name               = "conduit-app-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

# Permission: Session Manager access (no SSH keys needed)
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# The wrapper that lets EC2 instances use the role
resource "aws_iam_instance_profile" "app" {
  name = "conduit-app-profile"
  role = aws_iam_role.app.name
}