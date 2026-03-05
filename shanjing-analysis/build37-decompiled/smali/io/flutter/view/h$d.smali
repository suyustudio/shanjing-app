.class Lio/flutter/view/h$d;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Landroid/view/accessibility/AccessibilityManager$TouchExplorationStateChangeListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lio/flutter/view/h;-><init>(Landroid/view/View;Li0/a;Landroid/view/accessibility/AccessibilityManager;Landroid/content/ContentResolver;Lio/flutter/view/AccessibilityViewEmbedder;Lio/flutter/plugin/platform/q;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic a:Landroid/view/accessibility/AccessibilityManager;

.field final synthetic b:Lio/flutter/view/h;


# direct methods
.method constructor <init>(Lio/flutter/view/h;Landroid/view/accessibility/AccessibilityManager;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    iput-object p1, p0, Lio/flutter/view/h$d;->b:Lio/flutter/view/h;

    iput-object p2, p0, Lio/flutter/view/h$d;->a:Landroid/view/accessibility/AccessibilityManager;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onTouchExplorationStateChanged(Z)V
    .locals 2

    iget-object v0, p0, Lio/flutter/view/h$d;->b:Lio/flutter/view/h;

    invoke-static {v0}, Lio/flutter/view/h;->k(Lio/flutter/view/h;)Z

    move-result v0

    if-eqz v0, :cond_0

    return-void

    :cond_0
    if-nez p1, :cond_1

    iget-object v0, p0, Lio/flutter/view/h$d;->b:Lio/flutter/view/h;

    const/4 v1, 0x0

    invoke-static {v0, v1}, Lio/flutter/view/h;->n(Lio/flutter/view/h;Z)V

    iget-object v0, p0, Lio/flutter/view/h$d;->b:Lio/flutter/view/h;

    invoke-static {v0}, Lio/flutter/view/h;->h(Lio/flutter/view/h;)V

    :cond_1
    iget-object v0, p0, Lio/flutter/view/h$d;->b:Lio/flutter/view/h;

    invoke-static {v0}, Lio/flutter/view/h;->s(Lio/flutter/view/h;)Lio/flutter/view/h$k;

    move-result-object v0

    if-eqz v0, :cond_2

    iget-object v0, p0, Lio/flutter/view/h$d;->b:Lio/flutter/view/h;

    invoke-static {v0}, Lio/flutter/view/h;->s(Lio/flutter/view/h;)Lio/flutter/view/h$k;

    move-result-object v0

    iget-object v1, p0, Lio/flutter/view/h$d;->a:Landroid/view/accessibility/AccessibilityManager;

    invoke-virtual {v1}, Landroid/view/accessibility/AccessibilityManager;->isEnabled()Z

    move-result v1

    invoke-interface {v0, v1, p1}, Lio/flutter/view/h$k;->a(ZZ)V

    :cond_2
    return-void
.end method
