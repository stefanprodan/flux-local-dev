// brew install k6
import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
    duration: '30s',
    vus: 10,
    insecureSkipTLSVerify: true,
    hosts: {
      'podinfo.flux.local:80': '127.0.0.1:80',
      'podinfo.flux.local:443': '127.0.0.1:443',
    },
    thresholds: {
      http_req_failed: ['rate<0.01'], // http errors should be less than 1%
      http_req_duration: ['p(95)<500'], // 95 percent of response times must be below 500ms
    },
  };

export default function () {
const req1 = {
    method: 'GET',
    url: 'https://podinfo.flux.local',
    params: {
      headers: { 'Host': 'podinfo.flux.local' },
    },
  };

  const responses = http.batch([req1]);
}
