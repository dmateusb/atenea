import fs from 'fs/promises';
import path from 'path';
import OpenAI from 'openai';
import type { TTSOptions } from './types.js';

let openaiClient: OpenAI | null = null;

function getOpenAIClient(): OpenAI {
  if (!openaiClient) {
    if (!process.env.OPENAI_API_KEY) {
      throw new Error(
        'OPENAI_API_KEY environment variable is required. Please add it to your .env file.'
      );
    }
    openaiClient = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY,
    });
  }
  return openaiClient;
}

export async function generateSpeech(options: TTSOptions): Promise<string> {
  const { text, voice, model, outputPath } = options;

  console.log(`🎙️  Generating speech with voice: ${voice}`);

  try {
    const openai = getOpenAIClient();
    const mp3 = await openai.audio.speech.create({
      model,
      voice: voice as 'alloy' | 'echo' | 'fable' | 'onyx' | 'nova' | 'shimmer',
      input: text,
    });

    const buffer = Buffer.from(await mp3.arrayBuffer());

    // Ensure directory exists
    await fs.mkdir(path.dirname(outputPath), { recursive: true });

    // Write audio file
    await fs.writeFile(outputPath, buffer);

    console.log(`✅ Audio generated: ${outputPath}`);
    return outputPath;
  } catch (error) {
    if (error instanceof Error) {
      throw new Error(`TTS generation failed: ${error.message}`);
    }
    throw error;
  }
}

export async function textToSpeech(
  text: string,
  outputPath: string
): Promise<string> {
  const voice = process.env.TTS_VOICE || 'nova';
  const model = process.env.TTS_MODEL || 'tts-1';

  return generateSpeech({
    text,
    voice,
    model,
    outputPath,
  });
}
