#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { ProfilerStack } from '../lib/profiler-stack';
import { LambdaFunctionLogGroupAspect } from '../lib/aspects/lambda-function-log-group-aspect';

const app = new cdk.App();
const stack = new ProfilerStack(app, 'ProfilerStack', {});

cdk.Aspects.of(stack).add(new LambdaFunctionLogGroupAspect());
