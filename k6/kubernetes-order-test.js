import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 10,          // virtual users
  duration: '30s',  // test duration
                    // thresholds: {http_req_duration: ['p(95)<100'], http_req_failed: ['rate<0.01']},
};

export default function () {
  const payload = JSON.stringify({
    product_id: "books",
    quantity: 1,
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };

  const res = http.post('http://localhost:80/orders', payload, params);

  check(res, {
    'status is 201': (r) => r.status === 201,
  });

  sleep(0.5);
}
