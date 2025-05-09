#!/bin/bash

# 固定参数
STDDEV_INPUT_TOKENS=10
STDDEV_OUTPUT_TOKENS=10
# MODEL_NAME="deepseek-ai/DeepSeek-R1-Distill-Qwen-14B"
MODEL_NAME="${LLM_MODEL_ID:-deepseek-ai/DeepSeek-R1-Distill-Qwen-32B}"
#MODEL_NAME="deepseek-ai/DeepSeek-R1-Distill-Llama-70B"

export OPENAI_API_KEY="empty"
export OPENAI_API_BASE="${LLM_ENDPOINT}/v1"

# 要测试的并发列表
#CONCURRENT_LIST=(4 8 16 32 64 128)
#CONCURRENT_LIST=($(seq 2 128))
CONCURRENT_LIST=(1 2 4 6 8 10 12 14 16 18 20 22 24)


# 输入输出token长度列表
# MEAN_INPUT_TOKENS_LIST=(1024 2048 4096 6144 8192 10240 12288 14336 16384 18432 20480 22528 24576)
# MEAN_OUTPUT_TOKENS_LIST=(512 1024 2048 3072 4096 5120 6144 7168 8192 9216 10240 11264 12288)
# MEAN_INPUT_TOKENS_LIST=(1024 2048 4096 6144 8192)
# MEAN_OUTPUT_TOKENS_LIST=(512 1024 2048 3072 4096)
MEAN_INPUT_TOKENS_LIST=(1024)
MEAN_OUTPUT_TOKENS_LIST=(512)

# 创建结果文件夹
RESULTS_BASE_DIR="result_outputs"
mkdir -p "${RESULTS_BASE_DIR}"

# 循环所有长度组合
for ((i=0; i<${#MEAN_INPUT_TOKENS_LIST[@]}; i++)); do
  MEAN_INPUT_TOKENS=${MEAN_INPUT_TOKENS_LIST[$i]}
  MEAN_OUTPUT_TOKENS=${MEAN_OUTPUT_TOKENS_LIST[$i]}

  echo "============================"
  echo "🎯 Starting tests for MEAN_INPUT_TOKENS=${MEAN_INPUT_TOKENS}, MEAN_OUTPUT_TOKENS=${MEAN_OUTPUT_TOKENS}"

  for CONCURRENT_REQUESTS in "${CONCURRENT_LIST[@]}"
  do
    echo "🚀 Running with CONCURRENT_REQUESTS=${CONCURRENT_REQUESTS}"

    RESULT_DIR="${RESULTS_BASE_DIR}/concurrent_${CONCURRENT_REQUESTS}"
    mkdir -p "${RESULT_DIR}"

    # echo $((CONCURRENT_REQUESTS * 5))

    python token_benchmark_ray.py \
      --model "${MODEL_NAME}" \
      --mean-input-tokens ${MEAN_INPUT_TOKENS} \
      --stddev-input-tokens ${STDDEV_INPUT_TOKENS} \
      --mean-output-tokens ${MEAN_OUTPUT_TOKENS} \
      --stddev-output-tokens ${STDDEV_OUTPUT_TOKENS} \
      --max-num-completed-requests 256 \
      --timeout 580 \
      --num-concurrent-requests ${CONCURRENT_REQUESTS} \
      --results-dir "${RESULT_DIR}" \
      --llm-api openai \
      --additional-sampling-params '{}'

    echo "✅ Finished CONCURRENT_REQUESTS=${CONCURRENT_REQUESTS}"
    echo "----------------------------------------"
    sleep 20s
  done

  echo "🎯 Finished all concurrency tests for MEAN_INPUT_TOKENS=${MEAN_INPUT_TOKENS}"
  echo "============================"
done

echo "🎉 ALL TESTS COMPLETED."

