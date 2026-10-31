const fs = require('node:fs');
const path = require('node:path');

const eventType = process.argv[2];
const validEventTypes = new Set(['prompt', 'tool_use', 'subagent_start', 'subagent_stop', 'notification']);

if (!validEventTypes.has(eventType)) {
  throw new Error(`Unsupported hook event type: ${eventType ?? '(missing)'}`);
}

const input = fs.readFileSync(0, 'utf8');
const payload = JSON.parse(input);
const timestamp = payload.timestamp;
const timestampIso = typeof timestamp === 'number'
  ? new Date(timestamp).toISOString()
  : typeof timestamp === 'string'
    ? timestamp
    : new Date().toISOString();
const prompt = typeof payload.prompt === 'string' ? payload.prompt : undefined;
const taskTag = prompt?.match(/TASK-TAG:\s*(task-[a-z0-9-]+)/i)?.[1];
const record = {
  ts: timestampIso,
  event: eventType,
  session: payload.sessionId ?? payload.session_id ?? 'unknown',
};

if (eventType === 'prompt') {
  record.task = taskTag ?? 'untagged';
  record.prompt = prompt ?? '';
} else if (eventType === 'tool_use') {
  record.tool = payload.toolName ?? payload.tool_name ?? 'unknown';
} else if (eventType === 'subagent_start' || eventType === 'subagent_stop') {
  record.agent = payload.agentName ?? payload.agent_name ?? 'unknown';
} else if (eventType === 'notification') {
  record.message = payload.message ?? 'unknown';
}

const logPath = process.env.COPILOT_HOOK_LOG
  ? path.resolve(process.env.COPILOT_HOOK_LOG)
  : path.resolve(process.cwd(), 'submission/ai-logs/raw-session.jsonl');
fs.mkdirSync(path.dirname(logPath), { recursive: true });
fs.appendFileSync(logPath, `${JSON.stringify(record)}\n`, 'utf8');
process.stdout.write('{}\n');
