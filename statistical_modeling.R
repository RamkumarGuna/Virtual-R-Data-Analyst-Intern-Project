# ============================================================
# Week 3 Task: Statistical Analysis and Predictive Modeling using R
# Dataset: Video Game Sales with Ratings (cleaned in Week 1)
# Author: Ram Kumar Gunasekaran
# ============================================================

options(scipen = 999)
set.seed(42)
library(ggplot2)

df <- read.csv("vgsales_cleaned.csv", stringsAsFactors = FALSE)
df$Genre    <- as.factor(df$Genre)
df$Platform <- as.factor(df$Platform)
df$Rating   <- as.factor(df$Rating)

cat("Dataset loaded. Dimensions:\n")
print(dim(df))

dir.create("plots", showWarnings = FALSE)

# ============================================================
# 1. EXPLORATORY STATISTICAL ANALYSIS
# ============================================================

# --- 1.1 Normality test on Global_Sales (Shapiro-Wilk, sampled to 5000 due to R's limit) ---
set.seed(42)
sample_sales <- sample(df$Global_Sales_Capped, 5000)
shapiro_result <- shapiro.test(sample_sales)
cat("\n===== SHAPIRO-WILK NORMALITY TEST: Global_Sales_Capped =====\n")
print(shapiro_result)

# --- 1.2 Correlation significance test: Critic_Score vs Global_Sales ---
cor_test_result <- cor.test(df$Critic_Score, df$Global_Sales_Capped, method = "pearson")
cat("\n===== PEARSON CORRELATION TEST: Critic_Score vs Global_Sales =====\n")
print(cor_test_result)

# --- 1.3 Hypothesis test: Do PS3 games sell significantly differently than X360 games? ---
ps3_sales  <- df$Global_Sales_Capped[df$Platform == "PS3"]
x360_sales <- df$Global_Sales_Capped[df$Platform == "X360"]
t_test_result <- t.test(ps3_sales, x360_sales)
cat("\n===== TWO-SAMPLE T-TEST: PS3 vs X360 Global Sales =====\n")
print(t_test_result)

# --- 1.4 ANOVA: Does mean sales differ significantly across genres? ---
anova_model <- aov(Global_Sales_Capped ~ Genre, data = df)
anova_summary <- summary(anova_model)
cat("\n===== ONE-WAY ANOVA: Global_Sales_Capped ~ Genre =====\n")
print(anova_summary)

# ============================================================
# 2. REGRESSION MODEL — Predicting Global Sales
# ============================================================

# --- 2.1 Train/test split (80/20) ---
model_df <- df[, c("Global_Sales_Capped", "Critic_Score", "User_Score", "Critic_Count", "Genre", "Platform")]
model_df <- na.omit(model_df)

n <- nrow(model_df)
train_idx <- sample(seq_len(n), size = 0.8 * n)
train_data <- model_df[train_idx, ]
test_data  <- model_df[-train_idx, ]

cat("\n\nTraining rows:", nrow(train_data), " | Test rows:", nrow(test_data), "\n")

# --- 2.2 Fit linear regression ---
lm_model <- lm(Global_Sales_Capped ~ Critic_Score + User_Score + Critic_Count + Genre, data = train_data)
cat("\n===== LINEAR REGRESSION SUMMARY =====\n")
print(summary(lm_model))

# --- 2.3 Predict on test set & evaluate ---
test_data$Predicted <- predict(lm_model, newdata = test_data)
rmse <- sqrt(mean((test_data$Global_Sales_Capped - test_data$Predicted)^2))
mae  <- mean(abs(test_data$Global_Sales_Capped - test_data$Predicted))
r2_test <- 1 - sum((test_data$Global_Sales_Capped - test_data$Predicted)^2) /
               sum((test_data$Global_Sales_Capped - mean(test_data$Global_Sales_Capped))^2)

cat("\n===== REGRESSION TEST-SET PERFORMANCE =====\n")
cat("RMSE:", round(rmse, 4), "\n")
cat("MAE :", round(mae, 4), "\n")
cat("R-squared (test):", round(r2_test, 4), "\n")

# --- 2.4 Diagnostic plots ---
png("plots/01_residuals_vs_fitted.png", width = 900, height = 600, res = 130)
plot(lm_model, which = 1, main = "Residuals vs Fitted")
dev.off()

png("plots/02_qq_plot.png", width = 900, height = 600, res = 130)
plot(lm_model, which = 2, main = "Normal Q-Q")
dev.off()

p_pred_actual <- ggplot(test_data, aes(x = Global_Sales_Capped, y = Predicted)) +
  geom_point(alpha = 0.4, color = "#2E75B6") +
  geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +
  labs(title = "Predicted vs Actual Global Sales (Test Set)",
       x = "Actual Global Sales (Capped)", y = "Predicted Global Sales") +
  theme_minimal(base_size = 13)
ggsave("plots/03_predicted_vs_actual.png", p_pred_actual, width = 7, height = 5.5, dpi = 150)

# ============================================================
# 3. CLASSIFICATION MODEL — Predicting "Hit" Games (Top 10% Sales)
# ============================================================

# --- 3.1 Create binary target: Hit = top 10% of Global_Sales_Capped ---
hit_threshold <- quantile(df$Global_Sales_Capped, 0.90)
cat("\n\nHit threshold (90th percentile of Global_Sales_Capped):", round(hit_threshold, 3), "\n")

class_df <- df[, c("Global_Sales_Capped", "Critic_Score", "User_Score", "Critic_Count", "User_Count", "Genre")]
class_df <- na.omit(class_df)
class_df$Hit <- factor(ifelse(class_df$Global_Sales_Capped >= hit_threshold, "Hit", "NotHit"),
                        levels = c("NotHit", "Hit"))  # explicit level order: NotHit=0 (reference), Hit=1 (positive class)

cat("\nClass balance:\n")
print(table(class_df$Hit))

# --- 3.2 Train/test split ---
n2 <- nrow(class_df)
train_idx2 <- sample(seq_len(n2), size = 0.8 * n2)
train2 <- class_df[train_idx2, ]
test2  <- class_df[-train_idx2, ]

# --- 3.3 Fit logistic regression ---
logit_model <- glm(Hit ~ Critic_Score + User_Score + Critic_Count + User_Count + Genre,
                    data = train2, family = binomial)
cat("\n===== LOGISTIC REGRESSION SUMMARY =====\n")
print(summary(logit_model))

# --- 3.4 Predict & build confusion matrix ---
test2$Prob <- predict(logit_model, newdata = test2, type = "response")
test2$PredClass <- factor(ifelse(test2$Prob >= 0.5, "Hit", "NotHit"),
                           levels = c("NotHit", "Hit"))  # match Actual's level order so matrix rows/cols align

conf_matrix <- table(Predicted = test2$PredClass, Actual = test2$Hit)
cat("\n===== CONFUSION MATRIX (Test Set) =====\n")
print(conf_matrix)

accuracy  <- sum(diag(conf_matrix)) / sum(conf_matrix)
precision <- conf_matrix["Hit", "Hit"] / sum(conf_matrix["Hit", ])
recall    <- conf_matrix["Hit", "Hit"] / sum(conf_matrix[, "Hit"])
f1_score  <- 2 * precision * recall / (precision + recall)

cat("\n===== CLASSIFICATION METRICS =====\n")
cat("Accuracy :", round(accuracy, 4), "\n")
cat("Precision:", round(precision, 4), "\n")
cat("Recall   :", round(recall, 4), "\n")
cat("F1 Score :", round(f1_score, 4), "\n")

# --- 3.5 ROC Curve ---
library(pROC)
roc_obj <- roc(test2$Hit, test2$Prob, levels = c("NotHit", "Hit"), direction = "<")
auc_val <- auc(roc_obj)
cat("\nAUC:", round(auc_val, 4), "\n")

png("plots/04_roc_curve.png", width = 900, height = 700, res = 130)
plot(roc_obj, main = paste0("ROC Curve (AUC = ", round(auc_val, 3), ")"), col = "#2E75B6", lwd = 2)
dev.off()

# --- 3.6 Confusion matrix heatmap ---
cm_df <- as.data.frame(conf_matrix)
p_cm <- ggplot(cm_df, aes(x = Actual, y = Predicted, fill = Freq)) +
  geom_tile(color = "white") +
  geom_text(aes(label = Freq), size = 6) +
  scale_fill_gradient(low = "#DCE6F1", high = "#2E75B6") +
  labs(title = "Confusion Matrix — Hit Game Classifier") +
  theme_minimal(base_size = 13)
ggsave("plots/05_confusion_matrix.png", p_cm, width = 6, height = 5, dpi = 150)

cat("\n\nAll plots saved to /plots.\n")
cat("\n===== SCRIPT COMPLETE =====\n")
