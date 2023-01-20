data  "aws_ami" "server_ami" {
    owners = ["137112412989"]

    filter  {
        name = "name"
        values =["amzn2-ami-kernel-5.10-hvm-2.0.20221210.1-x86_64-gp2"]
    }
}