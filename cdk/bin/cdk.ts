#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { ProfilerStack } from '../lib/profiler-stack';

const app = new cdk.App();

new ProfilerStack(app, 'ProfilerStack', {});
