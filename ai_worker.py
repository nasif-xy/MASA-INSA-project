import os
import sys
from openai import OpenAI

def main():
    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        print("Error: OPENAI_API_KEY environment variable not found.")
        sys.exit(1)

    task = os.environ.get("TASK", "Refactor and update documentation")
    client = OpenAI(api_key=api_key)

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {"role": "system", "content": "You are a code assistant."},
            {"role": "user", "content": f"Generate a brief summary patch for task: {task}"}
        ]
    )

    with open("AI_CHANGES.md", "a", encoding="utf-8") as f:
        f.write(f"\n\n## Automated Patch\n{response.choices[0].message.content}\n")

if __name__ == "__main__":
    main()
