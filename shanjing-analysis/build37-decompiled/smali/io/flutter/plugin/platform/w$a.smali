.class Lio/flutter/plugin/platform/w$a;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Li0/l$g;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/flutter/plugin/platform/w;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic a:Lio/flutter/plugin/platform/w;


# direct methods
.method constructor <init>(Lio/flutter/plugin/platform/w;)V
    .locals 0

    iput-object p1, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static synthetic j(Lio/flutter/plugin/platform/w$a;Lio/flutter/plugin/platform/a0;FLi0/l$b;)V
    .locals 0

    invoke-direct {p0, p1, p2, p3}, Lio/flutter/plugin/platform/w$a;->k(Lio/flutter/plugin/platform/a0;FLi0/l$b;)V

    return-void
.end method

.method private synthetic k(Lio/flutter/plugin/platform/a0;FLi0/l$b;)V
    .locals 5

    iget-object v0, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {v0, p1}, Lio/flutter/plugin/platform/w;->s(Lio/flutter/plugin/platform/w;Lio/flutter/plugin/platform/a0;)V

    iget-object v0, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {v0}, Lio/flutter/plugin/platform/w;->p(Lio/flutter/plugin/platform/w;)Landroid/content/Context;

    move-result-object v0

    if-nez v0, :cond_0

    goto :goto_0

    :cond_0
    iget-object p2, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {p2}, Lio/flutter/plugin/platform/w;->m(Lio/flutter/plugin/platform/w;)F

    move-result p2

    :goto_0
    new-instance v0, Li0/l$c;

    iget-object v1, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-virtual {p1}, Lio/flutter/plugin/platform/a0;->e()I

    move-result v2

    int-to-double v2, v2

    invoke-static {v1, v2, v3, p2}, Lio/flutter/plugin/platform/w;->t(Lio/flutter/plugin/platform/w;DF)I

    move-result v1

    iget-object v2, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-virtual {p1}, Lio/flutter/plugin/platform/a0;->d()I

    move-result p1

    int-to-double v3, p1

    invoke-static {v2, v3, v4, p2}, Lio/flutter/plugin/platform/w;->t(Lio/flutter/plugin/platform/w;DF)I

    move-result p1

    invoke-direct {v0, v1, p1}, Li0/l$c;-><init>(II)V

    invoke-interface {p3, v0}, Li0/l$b;->a(Li0/l$c;)V

    return-void
.end method


# virtual methods
.method public a(Z)V
    .locals 1

    iget-object v0, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {v0, p1}, Lio/flutter/plugin/platform/w;->r(Lio/flutter/plugin/platform/w;Z)Z

    return-void
.end method

.method public b(IDD)V
    .locals 1

    iget-object v0, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-virtual {v0, p1}, Lio/flutter/plugin/platform/w;->b(I)Z

    move-result v0

    if-eqz v0, :cond_0

    return-void

    :cond_0
    iget-object v0, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {v0}, Lio/flutter/plugin/platform/w;->v(Lio/flutter/plugin/platform/w;)Landroid/util/SparseArray;

    move-result-object v0

    invoke-virtual {v0, p1}, Landroid/util/SparseArray;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lio/flutter/plugin/platform/p;

    if-nez v0, :cond_1

    new-instance p2, Ljava/lang/StringBuilder;

    invoke-direct {p2}, Ljava/lang/StringBuilder;-><init>()V

    const-string p3, "Setting offset for unknown platform view with id: "

    invoke-virtual {p2, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p2, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {p2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    const-string p2, "PlatformViewsController"

    invoke-static {p2, p1}, Lw/b;->b(Ljava/lang/String;Ljava/lang/String;)V

    return-void

    :cond_1
    iget-object p1, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {p1, p2, p3}, Lio/flutter/plugin/platform/w;->l(Lio/flutter/plugin/platform/w;D)I

    move-result p1

    iget-object p2, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {p2, p4, p5}, Lio/flutter/plugin/platform/w;->l(Lio/flutter/plugin/platform/w;D)I

    move-result p2

    invoke-virtual {v0}, Landroid/view/View;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;

    move-result-object p3

    check-cast p3, Landroid/widget/FrameLayout$LayoutParams;

    iput p1, p3, Landroid/widget/FrameLayout$LayoutParams;->topMargin:I

    iput p2, p3, Landroid/widget/FrameLayout$LayoutParams;->leftMargin:I

    invoke-virtual {v0, p3}, Lio/flutter/plugin/platform/p;->setLayoutParams(Landroid/widget/FrameLayout$LayoutParams;)V

    return-void
.end method

.method public c(II)V
    .locals 3
    .annotation build Landroid/annotation/TargetApi;
        value = 0x11
    .end annotation

    invoke-static {p2}, Lio/flutter/plugin/platform/w;->q(I)Z

    move-result v0

    if-eqz v0, :cond_3

    iget-object v0, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-virtual {v0, p1}, Lio/flutter/plugin/platform/w;->b(I)Z

    move-result v0

    const-string v1, "PlatformViewsController"

    if-eqz v0, :cond_0

    iget-object v0, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    iget-object v0, v0, Lio/flutter/plugin/platform/w;->i:Ljava/util/HashMap;

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v0, v2}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lio/flutter/plugin/platform/a0;

    invoke-virtual {v0}, Lio/flutter/plugin/platform/a0;->f()Landroid/view/View;

    move-result-object v0

    goto :goto_1

    :cond_0
    iget-object v0, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {v0}, Lio/flutter/plugin/platform/w;->B(Lio/flutter/plugin/platform/w;)Landroid/util/SparseArray;

    move-result-object v0

    invoke-virtual {v0, p1}, Landroid/util/SparseArray;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lio/flutter/plugin/platform/k;

    if-nez v0, :cond_1

    new-instance p2, Ljava/lang/StringBuilder;

    invoke-direct {p2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v0, "Setting direction to an unknown view with id: "

    :goto_0
    invoke-virtual {p2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p2, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {p2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v1, p1}, Lw/b;->b(Ljava/lang/String;Ljava/lang/String;)V

    return-void

    :cond_1
    invoke-interface {v0}, Lio/flutter/plugin/platform/k;->l()Landroid/view/View;

    move-result-object v0

    :goto_1
    if-nez v0, :cond_2

    new-instance p2, Ljava/lang/StringBuilder;

    invoke-direct {p2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v0, "Setting direction to a null view with id: "

    goto :goto_0

    :cond_2
    invoke-virtual {v0, p2}, Landroid/view/View;->setLayoutDirection(I)V

    return-void

    :cond_3
    new-instance v0, Ljava/lang/IllegalStateException;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Trying to set unknown direction value: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string p2, "(view id: "

    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string p1, ")"

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {v0, p1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0
.end method

.method public d(Li0/l$d;)V
    .locals 2
    .annotation build Landroid/annotation/TargetApi;
        value = 0x13
    .end annotation

    iget-object v0, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    const/16 v1, 0x13

    invoke-static {v0, v1}, Lio/flutter/plugin/platform/w;->i(Lio/flutter/plugin/platform/w;I)V

    iget-object v0, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {v0, p1}, Lio/flutter/plugin/platform/w;->j(Lio/flutter/plugin/platform/w;Li0/l$d;)V

    iget-object v0, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    const/4 v1, 0x0

    invoke-virtual {v0, p1, v1}, Lio/flutter/plugin/platform/w;->M(Li0/l$d;Z)Lio/flutter/plugin/platform/k;

    move-result-object v0

    iget-object v1, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {v1, v0, p1}, Lio/flutter/plugin/platform/w;->u(Lio/flutter/plugin/platform/w;Lio/flutter/plugin/platform/k;Li0/l$d;)V

    return-void
.end method

.method public e(I)V
    .locals 3

    iget-object v0, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-virtual {v0, p1}, Lio/flutter/plugin/platform/w;->b(I)Z

    move-result v0

    const-string v1, "PlatformViewsController"

    if-eqz v0, :cond_0

    iget-object v0, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    iget-object v0, v0, Lio/flutter/plugin/platform/w;->i:Ljava/util/HashMap;

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v0, v2}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lio/flutter/plugin/platform/a0;

    invoke-virtual {v0}, Lio/flutter/plugin/platform/a0;->f()Landroid/view/View;

    move-result-object v0

    goto :goto_1

    :cond_0
    iget-object v0, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {v0}, Lio/flutter/plugin/platform/w;->B(Lio/flutter/plugin/platform/w;)Landroid/util/SparseArray;

    move-result-object v0

    invoke-virtual {v0, p1}, Landroid/util/SparseArray;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lio/flutter/plugin/platform/k;

    if-nez v0, :cond_1

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Clearing focus on an unknown view with id: "

    :goto_0
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v1, p1}, Lw/b;->b(Ljava/lang/String;Ljava/lang/String;)V

    return-void

    :cond_1
    invoke-interface {v0}, Lio/flutter/plugin/platform/k;->l()Landroid/view/View;

    move-result-object v0

    :goto_1
    if-nez v0, :cond_2

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Clearing focus on a null view with id: "

    goto :goto_0

    :cond_2
    invoke-virtual {v0}, Landroid/view/View;->clearFocus()V

    return-void
.end method

.method public f(Li0/l$f;)V
    .locals 4

    iget v0, p1, Li0/l$f;->a:I

    iget-object v1, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {v1}, Lio/flutter/plugin/platform/w;->p(Lio/flutter/plugin/platform/w;)Landroid/content/Context;

    move-result-object v1

    invoke-virtual {v1}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v1

    invoke-virtual {v1}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;

    move-result-object v1

    iget v1, v1, Landroid/util/DisplayMetrics;->density:F

    iget-object v2, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-virtual {v2, v0}, Lio/flutter/plugin/platform/w;->b(I)Z

    move-result v2

    if-eqz v2, :cond_0

    iget-object v2, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    iget-object v2, v2, Lio/flutter/plugin/platform/w;->i:Ljava/util/HashMap;

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    invoke-virtual {v2, v0}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lio/flutter/plugin/platform/a0;

    iget-object v2, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    const/4 v3, 0x1

    invoke-virtual {v2, v1, p1, v3}, Lio/flutter/plugin/platform/w;->v0(FLi0/l$f;Z)Landroid/view/MotionEvent;

    move-result-object p1

    invoke-virtual {v0, p1}, Lio/flutter/plugin/platform/a0;->b(Landroid/view/MotionEvent;)V

    return-void

    :cond_0
    iget-object v2, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {v2}, Lio/flutter/plugin/platform/w;->B(Lio/flutter/plugin/platform/w;)Landroid/util/SparseArray;

    move-result-object v2

    invoke-virtual {v2, v0}, Landroid/util/SparseArray;->get(I)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lio/flutter/plugin/platform/k;

    const-string v3, "PlatformViewsController"

    if-nez v2, :cond_1

    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "Sending touch to an unknown view with id: "

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v3, p1}, Lw/b;->b(Ljava/lang/String;Ljava/lang/String;)V

    return-void

    :cond_1
    invoke-interface {v2}, Lio/flutter/plugin/platform/k;->l()Landroid/view/View;

    move-result-object v2

    if-nez v2, :cond_2

    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "Sending touch to a null view with id: "

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v3, p1}, Lw/b;->b(Ljava/lang/String;Ljava/lang/String;)V

    return-void

    :cond_2
    iget-object v0, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    const/4 v3, 0x0

    invoke-virtual {v0, v1, p1, v3}, Lio/flutter/plugin/platform/w;->v0(FLi0/l$f;Z)Landroid/view/MotionEvent;

    move-result-object p1

    invoke-virtual {v2, p1}, Landroid/view/View;->dispatchTouchEvent(Landroid/view/MotionEvent;)Z

    return-void
.end method

.method public g(Li0/l$e;Li0/l$b;)V
    .locals 4

    iget-object v0, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    iget-wide v1, p1, Li0/l$e;->b:D

    invoke-static {v0, v1, v2}, Lio/flutter/plugin/platform/w;->l(Lio/flutter/plugin/platform/w;D)I

    move-result v0

    iget-object v1, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    iget-wide v2, p1, Li0/l$e;->c:D

    invoke-static {v1, v2, v3}, Lio/flutter/plugin/platform/w;->l(Lio/flutter/plugin/platform/w;D)I

    move-result v1

    iget p1, p1, Li0/l$e;->a:I

    iget-object v2, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-virtual {v2, p1}, Lio/flutter/plugin/platform/w;->b(I)Z

    move-result v2

    if-eqz v2, :cond_0

    iget-object v2, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {v2}, Lio/flutter/plugin/platform/w;->m(Lio/flutter/plugin/platform/w;)F

    move-result v2

    iget-object v3, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    iget-object v3, v3, Lio/flutter/plugin/platform/w;->i:Ljava/util/HashMap;

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    invoke-virtual {v3, p1}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Lio/flutter/plugin/platform/a0;

    iget-object v3, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {v3, p1}, Lio/flutter/plugin/platform/w;->n(Lio/flutter/plugin/platform/w;Lio/flutter/plugin/platform/a0;)V

    new-instance v3, Lio/flutter/plugin/platform/v;

    invoke-direct {v3, p0, p1, v2, p2}, Lio/flutter/plugin/platform/v;-><init>(Lio/flutter/plugin/platform/w$a;Lio/flutter/plugin/platform/a0;FLi0/l$b;)V

    invoke-virtual {p1, v0, v1, v3}, Lio/flutter/plugin/platform/a0;->i(IILjava/lang/Runnable;)V

    return-void

    :cond_0
    iget-object v2, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {v2}, Lio/flutter/plugin/platform/w;->B(Lio/flutter/plugin/platform/w;)Landroid/util/SparseArray;

    move-result-object v2

    invoke-virtual {v2, p1}, Landroid/util/SparseArray;->get(I)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lio/flutter/plugin/platform/k;

    iget-object v3, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {v3}, Lio/flutter/plugin/platform/w;->v(Lio/flutter/plugin/platform/w;)Landroid/util/SparseArray;

    move-result-object v3

    invoke-virtual {v3, p1}, Landroid/util/SparseArray;->get(I)Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Lio/flutter/plugin/platform/p;

    if-eqz v2, :cond_5

    if-nez v3, :cond_1

    goto :goto_0

    :cond_1
    invoke-virtual {v3}, Lio/flutter/plugin/platform/p;->getRenderTargetWidth()I

    move-result p1

    if-gt v0, p1, :cond_2

    invoke-virtual {v3}, Lio/flutter/plugin/platform/p;->getRenderTargetHeight()I

    move-result p1

    if-le v1, p1, :cond_3

    :cond_2
    invoke-virtual {v3, v0, v1}, Lio/flutter/plugin/platform/p;->b(II)V

    :cond_3
    invoke-virtual {v3}, Landroid/view/View;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;

    move-result-object p1

    iput v0, p1, Landroid/view/ViewGroup$LayoutParams;->width:I

    iput v1, p1, Landroid/view/ViewGroup$LayoutParams;->height:I

    invoke-virtual {v3, p1}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    invoke-interface {v2}, Lio/flutter/plugin/platform/k;->l()Landroid/view/View;

    move-result-object p1

    if-eqz p1, :cond_4

    invoke-virtual {p1}, Landroid/view/View;->getLayoutParams()Landroid/view/ViewGroup$LayoutParams;

    move-result-object v2

    iput v0, v2, Landroid/view/ViewGroup$LayoutParams;->width:I

    iput v1, v2, Landroid/view/ViewGroup$LayoutParams;->height:I

    invoke-virtual {p1, v2}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    :cond_4
    new-instance p1, Li0/l$c;

    iget-object v0, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-virtual {v3}, Lio/flutter/plugin/platform/p;->getRenderTargetWidth()I

    move-result v1

    int-to-double v1, v1

    invoke-static {v0, v1, v2}, Lio/flutter/plugin/platform/w;->o(Lio/flutter/plugin/platform/w;D)I

    move-result v0

    iget-object v1, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-virtual {v3}, Lio/flutter/plugin/platform/p;->getRenderTargetHeight()I

    move-result v2

    int-to-double v2, v2

    invoke-static {v1, v2, v3}, Lio/flutter/plugin/platform/w;->o(Lio/flutter/plugin/platform/w;D)I

    move-result v1

    invoke-direct {p1, v0, v1}, Li0/l$c;-><init>(II)V

    invoke-interface {p2, p1}, Li0/l$b;->a(Li0/l$c;)V

    return-void

    :cond_5
    :goto_0
    new-instance p2, Ljava/lang/StringBuilder;

    invoke-direct {p2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v0, "Resizing unknown platform view with id: "

    invoke-virtual {p2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p2, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {p2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    const-string p2, "PlatformViewsController"

    invoke-static {p2, p1}, Lw/b;->b(Ljava/lang/String;Ljava/lang/String;)V

    return-void
.end method

.method public h(Li0/l$d;)J
    .locals 5
    .annotation build Landroid/annotation/TargetApi;
        value = 0x14
    .end annotation

    iget-object v0, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {v0, p1}, Lio/flutter/plugin/platform/w;->j(Lio/flutter/plugin/platform/w;Li0/l$d;)V

    iget v0, p1, Li0/l$d;->a:I

    iget-object v1, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {v1}, Lio/flutter/plugin/platform/w;->v(Lio/flutter/plugin/platform/w;)Landroid/util/SparseArray;

    move-result-object v1

    invoke-virtual {v1, v0}, Landroid/util/SparseArray;->get(I)Ljava/lang/Object;

    move-result-object v1

    if-nez v1, :cond_6

    iget-object v1, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {v1}, Lio/flutter/plugin/platform/w;->w(Lio/flutter/plugin/platform/w;)Lio/flutter/view/TextureRegistry;

    move-result-object v1

    if-eqz v1, :cond_5

    iget-object v1, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {v1}, Lio/flutter/plugin/platform/w;->x(Lio/flutter/plugin/platform/w;)Lio/flutter/embedding/android/s;

    move-result-object v1

    if-eqz v1, :cond_4

    iget-object v0, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    const/4 v1, 0x1

    invoke-virtual {v0, p1, v1}, Lio/flutter/plugin/platform/w;->M(Li0/l$d;Z)Lio/flutter/plugin/platform/k;

    move-result-object v0

    invoke-interface {v0}, Lio/flutter/plugin/platform/k;->l()Landroid/view/View;

    move-result-object v2

    invoke-virtual {v2}, Landroid/view/View;->getParent()Landroid/view/ViewParent;

    move-result-object v3

    if-nez v3, :cond_3

    sget v3, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v4, 0x17

    if-lt v3, v4, :cond_0

    invoke-static {}, Lio/flutter/plugin/platform/w;->y()[Ljava/lang/Class;

    move-result-object v3

    invoke-static {v2, v3}, Lp0/i;->g(Landroid/view/View;[Ljava/lang/Class;)Z

    move-result v2

    if-nez v2, :cond_0

    goto :goto_0

    :cond_0
    const/4 v1, 0x0

    :goto_0
    if-nez v1, :cond_2

    iget-object v1, p1, Li0/l$d;->h:Li0/l$d$a;

    sget-object v2, Li0/l$d$a;->e:Li0/l$d$a;

    if-ne v1, v2, :cond_1

    iget-object v1, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {v1, v0, p1}, Lio/flutter/plugin/platform/w;->u(Lio/flutter/plugin/platform/w;Lio/flutter/plugin/platform/k;Li0/l$d;)V

    const-wide/16 v0, -0x2

    return-wide v0

    :cond_1
    iget-object v1, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {v1}, Lio/flutter/plugin/platform/w;->z(Lio/flutter/plugin/platform/w;)Z

    move-result v1

    if-nez v1, :cond_2

    iget-object v1, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {v1, v0, p1}, Lio/flutter/plugin/platform/w;->A(Lio/flutter/plugin/platform/w;Lio/flutter/plugin/platform/k;Li0/l$d;)J

    move-result-wide v0

    return-wide v0

    :cond_2
    iget-object v1, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-virtual {v1, v0, p1}, Lio/flutter/plugin/platform/w;->I(Lio/flutter/plugin/platform/k;Li0/l$d;)J

    move-result-wide v0

    return-wide v0

    :cond_3
    new-instance p1, Ljava/lang/IllegalStateException;

    const-string v0, "The Android view returned from PlatformView#getView() was already added to a parent view."

    invoke-direct {p1, v0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p1

    :cond_4
    new-instance p1, Ljava/lang/IllegalStateException;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Flutter view is null. This means the platform views controller doesn\'t have an attached view, view id: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-direct {p1, v0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p1

    :cond_5
    new-instance p1, Ljava/lang/IllegalStateException;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Texture registry is null. This means that platform views controller was detached, view id: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-direct {p1, v0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p1

    :cond_6
    new-instance p1, Ljava/lang/IllegalStateException;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Trying to create an already created platform view, view id: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-direct {p1, v0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p1
.end method

.method public i(I)V
    .locals 4

    iget-object v0, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {v0}, Lio/flutter/plugin/platform/w;->B(Lio/flutter/plugin/platform/w;)Landroid/util/SparseArray;

    move-result-object v0

    invoke-virtual {v0, p1}, Landroid/util/SparseArray;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lio/flutter/plugin/platform/k;

    const-string v1, "PlatformViewsController"

    if-nez v0, :cond_0

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "Disposing unknown platform view with id: "

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v1, p1}, Lw/b;->b(Ljava/lang/String;Ljava/lang/String;)V

    return-void

    :cond_0
    invoke-interface {v0}, Lio/flutter/plugin/platform/k;->l()Landroid/view/View;

    move-result-object v2

    if-eqz v2, :cond_1

    invoke-interface {v0}, Lio/flutter/plugin/platform/k;->l()Landroid/view/View;

    move-result-object v2

    invoke-virtual {v2}, Landroid/view/View;->getParent()Landroid/view/ViewParent;

    move-result-object v3

    check-cast v3, Landroid/view/ViewGroup;

    if-eqz v3, :cond_1

    invoke-virtual {v3, v2}, Landroid/view/ViewGroup;->removeView(Landroid/view/View;)V

    :cond_1
    iget-object v2, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {v2}, Lio/flutter/plugin/platform/w;->B(Lio/flutter/plugin/platform/w;)Landroid/util/SparseArray;

    move-result-object v2

    invoke-virtual {v2, p1}, Landroid/util/SparseArray;->remove(I)V

    :try_start_0
    invoke-interface {v0}, Lio/flutter/plugin/platform/k;->a()V
    :try_end_0
    .catch Ljava/lang/RuntimeException; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception v0

    const-string v2, "Disposing platform view threw an exception"

    invoke-static {v1, v2, v0}, Lw/b;->c(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    :goto_0
    iget-object v0, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-virtual {v0, p1}, Lio/flutter/plugin/platform/w;->b(I)Z

    move-result v0

    if-eqz v0, :cond_3

    iget-object v0, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    iget-object v0, v0, Lio/flutter/plugin/platform/w;->i:Ljava/util/HashMap;

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lio/flutter/plugin/platform/a0;

    invoke-virtual {v0}, Lio/flutter/plugin/platform/a0;->f()Landroid/view/View;

    move-result-object v1

    if-eqz v1, :cond_2

    iget-object v2, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    iget-object v2, v2, Lio/flutter/plugin/platform/w;->j:Ljava/util/HashMap;

    invoke-virtual {v1}, Landroid/view/View;->getContext()Landroid/content/Context;

    move-result-object v1

    invoke-virtual {v2, v1}, Ljava/util/HashMap;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    :cond_2
    invoke-virtual {v0}, Lio/flutter/plugin/platform/a0;->c()V

    iget-object v0, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    iget-object v0, v0, Lio/flutter/plugin/platform/w;->i:Ljava/util/HashMap;

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    invoke-virtual {v0, p1}, Ljava/util/HashMap;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    return-void

    :cond_3
    iget-object v0, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {v0}, Lio/flutter/plugin/platform/w;->v(Lio/flutter/plugin/platform/w;)Landroid/util/SparseArray;

    move-result-object v0

    invoke-virtual {v0, p1}, Landroid/util/SparseArray;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lio/flutter/plugin/platform/p;

    if-eqz v0, :cond_5

    invoke-virtual {v0}, Landroid/view/ViewGroup;->removeAllViews()V

    invoke-virtual {v0}, Lio/flutter/plugin/platform/p;->a()V

    invoke-virtual {v0}, Lio/flutter/plugin/platform/p;->c()V

    invoke-virtual {v0}, Landroid/view/View;->getParent()Landroid/view/ViewParent;

    move-result-object v1

    check-cast v1, Landroid/view/ViewGroup;

    if-eqz v1, :cond_4

    invoke-virtual {v1, v0}, Landroid/view/ViewGroup;->removeView(Landroid/view/View;)V

    :cond_4
    iget-object v0, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {v0}, Lio/flutter/plugin/platform/w;->v(Lio/flutter/plugin/platform/w;)Landroid/util/SparseArray;

    move-result-object v0

    invoke-virtual {v0, p1}, Landroid/util/SparseArray;->remove(I)V

    return-void

    :cond_5
    iget-object v0, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {v0}, Lio/flutter/plugin/platform/w;->k(Lio/flutter/plugin/platform/w;)Landroid/util/SparseArray;

    move-result-object v0

    invoke-virtual {v0, p1}, Landroid/util/SparseArray;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, La0/a;

    if-eqz v0, :cond_7

    invoke-virtual {v0}, Landroid/view/ViewGroup;->removeAllViews()V

    invoke-virtual {v0}, La0/a;->b()V

    invoke-virtual {v0}, Landroid/view/View;->getParent()Landroid/view/ViewParent;

    move-result-object v1

    check-cast v1, Landroid/view/ViewGroup;

    if-eqz v1, :cond_6

    invoke-virtual {v1, v0}, Landroid/view/ViewGroup;->removeView(Landroid/view/View;)V

    :cond_6
    iget-object v0, p0, Lio/flutter/plugin/platform/w$a;->a:Lio/flutter/plugin/platform/w;

    invoke-static {v0}, Lio/flutter/plugin/platform/w;->k(Lio/flutter/plugin/platform/w;)Landroid/util/SparseArray;

    move-result-object v0

    invoke-virtual {v0, p1}, Landroid/util/SparseArray;->remove(I)V

    :cond_7
    return-void
.end method
