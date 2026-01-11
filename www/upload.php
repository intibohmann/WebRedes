<?php
$raw = file_get_contents('php://input');

if (!$raw) {
    http_response_code(400);
    exit('Payload vazio');
}

$data = json_decode($raw, true);

if (json_last_error() !== JSON_ERROR_NONE) {
    http_response_code(400);
    exit('JSON inválido');
}

$dir = __DIR__ . '/logs';

if (!is_dir($dir)) {
    mkdir($dir, 0755, true);
}

file_put_contents(
    $dir . '/scan_' . date('Ymd_His') . '.json',
    json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE)
);

echo json_encode(['status' => 'ok']);
