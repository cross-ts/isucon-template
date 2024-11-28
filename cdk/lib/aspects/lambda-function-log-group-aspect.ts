import * as cdk from 'aws-cdk-lib';
import { IConstruct } from 'constructs';
import * as logs from 'aws-cdk-lib/aws-logs';

export class LambdaFunctionLogGroupAspect implements cdk.IAspect {
  public visit(node: IConstruct): void {
    // HACK:
    // Raw Constructを使用しないとAWS側で勝手に作成するような
    // CustomResourceのLambda Functionに対しての変更が効かない
    const resource = node as cdk.CfnResource;
    if (resource.cfnResourceType !== 'AWS::Lambda::Function') {
      return;
    }

    /**
     * FIXME:
     * CustomS3AutoDeleteObjectsのように削除時にログを残すような
     * CustomResourceの場合は削除後に再実行されてログが残ってしまう
     */
    const logGroup = new logs.LogGroup(node, 'LogGroup', {
      removalPolicy: cdk.RemovalPolicy.DESTROY,
      retention: cdk.aws_logs.RetentionDays.ONE_DAY,
    });

    // 作成したログに対してログを出力するように設定
    resource.addPropertyOverride('LoggingConfig', {
      LogGroup: logGroup.logGroupName,
      LogFormat: 'JSON',
    });
  }
}
