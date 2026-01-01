import { spawn } from 'child_process';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export interface GenerateVideoParams {
  imagePath: string;
  audioPath: string;
  outputPath: string;
}

export async function generateVideo(
  params: GenerateVideoParams
): Promise<string> {
  const { imagePath, audioPath, outputPath } = params;

  const pythonScript = path.join(
    __dirname,
    '..',
    'python',
    'generate_video.py'
  );
  const venvPython = path.join(__dirname, '..', 'venv', 'bin', 'python3');

  console.log('🎬 Starting video generation...');
  console.log(`📸 Image: ${imagePath}`);
  console.log(`🎵 Audio: ${audioPath}`);
  console.log(`🎥 Output: ${outputPath}`);

  return new Promise((resolve, reject) => {
    const process = spawn(venvPython, [
      pythonScript,
      '--image',
      imagePath,
      '--audio',
      audioPath,
      '--output',
      outputPath,
    ]);

    let stdout = '';
    let stderr = '';

    process.stdout.on('data', (data) => {
      const text = data.toString();
      stdout += text;
      console.log(text.trim());
    });

    process.stderr.on('data', (data) => {
      const text = data.toString();
      stderr += text;
      console.error(text.trim());
    });

    process.on('close', (code) => {
      if (code === 0) {
        console.log('✅ Video generation completed successfully');
        resolve(outputPath);
      } else {
        reject(
          new Error(
            `Video generation failed with code ${code}\nStderr: ${stderr}`
          )
        );
      }
    });

    process.on('error', (error) => {
      reject(new Error(`Failed to spawn Python process: ${error.message}`));
    });
  });
}
