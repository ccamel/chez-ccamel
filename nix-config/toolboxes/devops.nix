[
  {
    package = { pkgs, ... }: pkgs.kubectl;
    documentation = {
      name = "kubectl";
      description = "Kubernetes command-line tool.";
      url = "https://kubernetes.io/docs/reference/kubectl/";
      visibility = "public";
    };
  }
  {
    package = { pkgs, ... }: pkgs.kubernetes-helm;
    documentation = {
      name = "Helm";
      description = "Kubernetes package manager.";
      url = "https://helm.sh/";
      visibility = "public";
    };
  }
  {
    package = { pkgs, ... }: pkgs.helmfile;
    documentation = {
      name = "Helmfile";
      description = "Declarative Helm chart deployment tool.";
      url = "https://helmfile.readthedocs.io/";
      visibility = "public";
    };
  }
  {
    package = { pkgs, ... }: pkgs.k9s;
    documentation = {
      name = "k9s";
      description = "Terminal UI for Kubernetes.";
      url = "https://k9scli.io/";
      visibility = "public";
    };
  }
  {
    package = { pkgs, ... }: pkgs.kustomize;
    documentation = {
      name = "Kustomize";
      description = "Kubernetes configuration customization tool.";
      url = "https://kustomize.io/";
      visibility = "public";
    };
  }
  {
    package = { pkgs, ... }: pkgs.google-cloud-sdk;
    documentation = {
      name = "gcloud";
      description = "Google Cloud command-line interface.";
      url = "https://cloud.google.com/sdk/gcloud";
      visibility = "public";
    };
  }
  {
    package = { pkgs, ... }: pkgs.terraform;
    documentation = {
      name = "Terraform";
      description = "Infrastructure as code tool.";
      url = "https://www.terraform.io/";
      visibility = "public";
    };
  }
  {
    package = { pkgs, ... }: pkgs.terraform-ls;
  }
  {
    package = { pkgs, ... }: pkgs.tflint;
  }
  {
    package = { pkgs, ... }: pkgs.terragrunt;
    documentation = {
      name = "Terragrunt";
      description = "Terraform orchestration and DRY configuration tool.";
      url = "https://terragrunt.gruntwork.io/";
      visibility = "public";
    };
  }
  {
    package = { pkgs, ... }: pkgs.trivy;
    documentation = {
      name = "Trivy";
      description = "Cloud-native vulnerability and misconfiguration scanner.";
      url = "https://trivy.dev/";
      visibility = "public";
    };
  }
]
