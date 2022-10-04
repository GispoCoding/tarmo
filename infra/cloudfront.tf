# S3 bucket
resource "aws_s3_bucket" "static_react_bucket" {
  # okay, let's have one bucket for each distribution and deployment
  bucket = var.AWS_BUCKET_NAME
  acl    = "private"

  tags = merge(local.default_tags, {
    Name = var.AWS_BUCKET_NAME
  })

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.static_react_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# Cloudfront
data "aws_cloudfront_cache_policy" "ManagedCachingOptimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "ManagedCachingDisabled" {
  name = "Managed-CachingDisabled"
}


resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "${var.prefix}-react-app OAI"
}

resource "aws_cloudfront_distribution" "cf_distribution" {
  origin {
    domain_name = aws_s3_bucket.static_react_bucket.bucket_regional_domain_name
    # here the origin id is different for each deployment (workspace)
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  default_root_object = "index.html"
  aliases             = var.enable_route53_record ? concat([local.frontend_dns_alias], var.alternate_domains) : var.alternate_domains

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    cache_policy_id = data.aws_cloudfront_cache_policy.ManagedCachingOptimized.id

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  ordered_cache_behavior {
    # Don't cache index.html to always get newest resources when releasing new version
    path_pattern     = "/index.html"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    cache_policy_id = data.aws_cloudfront_cache_policy.ManagedCachingDisabled.id

    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  ordered_cache_behavior {
    # Don't cache map styles
    path_pattern     = "/map-styles/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    cache_policy_id = data.aws_cloudfront_cache_policy.ManagedCachingDisabled.id

    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }


  price_class = "PriceClass_100"

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = var.enable_route53_record ? aws_acm_certificate.frontend[0].arn : var.alternate_domain_certificate_arn
    ssl_support_method             = "sni-only"
  }

  retain_on_delete = true

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  tags = local.default_tags
}

# Cloudfront S3 policy

data "aws_iam_policy_document" "react_app_s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static_react_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "react_app_bucket_policy" {
  bucket = aws_s3_bucket.static_react_bucket.id
  policy = data.aws_iam_policy_document.react_app_s3_policy.json
}
