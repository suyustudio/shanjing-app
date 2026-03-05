.class Lio/flutter/view/h$b;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Landroid/view/accessibility/AccessibilityManager$AccessibilityStateChangeListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/flutter/view/h;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic a:Lio/flutter/view/h;


# direct methods
.method constructor <init>(Lio/flutter/view/h;)V
    .locals 0

    iput-object p1, p0, Lio/flutter/view/h$b;->a:Lio/flutter/view/h;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onAccessibilityStateChanged(Z)V
    .locals 2

    iget-object v0, p0, Lio/flutter/view/h$b;->a:Lio/flutter/view/h;

    invoke-static {v0}, Lio/flutter/view/h;->k(Lio/flutter/view/h;)Z

    move-result v0

    if-eqz v0, :cond_0

    return-void

    :cond_0
    iget-object v0, p0, Lio/flutter/view/h$b;->a:Lio/flutter/view/h;

    if-eqz p1, :cond_1

    invoke-static {v0}, Lio/flutter/view/h;->m(Lio/flutter/view/h;)Li0/a;

    move-result-object v0

    iget-object v1, p0, Lio/flutter/view/h$b;->a:Lio/flutter/view/h;

    invoke-static {v1}, Lio/flutter/view/h;->l(Lio/flutter/view/h;)Li0/a$b;

    move-result-object v1

    invoke-virtual {v0, v1}, Li0/a;->g(Li0/a$b;)V

    iget-object v0, p0, Lio/flutter/view/h$b;->a:Lio/flutter/view/h;

    invoke-static {v0}, Lio/flutter/view/h;->m(Lio/flutter/view/h;)Li0/a;

    move-result-object v0

    invoke-virtual {v0}, Li0/a;->e()V

    goto :goto_0

    :cond_1
    const/4 v1, 0x0

    invoke-static {v0, v1}, Lio/flutter/view/h;->n(Lio/flutter/view/h;Z)V

    iget-object v0, p0, Lio/flutter/view/h$b;->a:Lio/flutter/view/h;

    invoke-static {v0}, Lio/flutter/view/h;->m(Lio/flutter/view/h;)Li0/a;

    move-result-object v0

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Li0/a;->g(Li0/a$b;)V

    iget-object v0, p0, Lio/flutter/view/h$b;->a:Lio/flutter/view/h;

    invoke-static {v0}, Lio/flutter/view/h;->m(Lio/flutter/view/h;)Li0/a;

    move-result-object v0

    invoke-virtual {v0}, Li0/a;->d()V

    :goto_0
    iget-object v0, p0, Lio/flutter/view/h$b;->a:Lio/flutter/view/h;

    invoke-static {v0}, Lio/flutter/view/h;->s(Lio/flutter/view/h;)Lio/flutter/view/h$k;

    move-result-object v0

    if-eqz v0, :cond_2

    iget-object v0, p0, Lio/flutter/view/h$b;->a:Lio/flutter/view/h;

    invoke-static {v0}, Lio/flutter/view/h;->s(Lio/flutter/view/h;)Lio/flutter/view/h$k;

    move-result-object v0

    iget-object v1, p0, Lio/flutter/view/h$b;->a:Lio/flutter/view/h;

    invoke-static {v1}, Lio/flutter/view/h;->t(Lio/flutter/view/h;)Landroid/view/accessibility/AccessibilityManager;

    move-result-object v1

    invoke-virtual {v1}, Landroid/view/accessibility/AccessibilityManager;->isTouchExplorationEnabled()Z

    move-result v1

    invoke-interface {v0, p1, v1}, Lio/flutter/view/h$k;->a(ZZ)V

    :cond_2
    return-void
.end method
