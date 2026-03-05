.class Landroidx/core/view/t$j;
.super Landroidx/core/view/t$i;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Landroidx/core/view/t;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0xa
    name = "j"
.end annotation


# instance fields
.field private n:Landroidx/core/graphics/a;

.field private o:Landroidx/core/graphics/a;

.field private p:Landroidx/core/graphics/a;


# direct methods
.method constructor <init>(Landroidx/core/view/t;Landroid/view/WindowInsets;)V
    .locals 0

    invoke-direct {p0, p1, p2}, Landroidx/core/view/t$i;-><init>(Landroidx/core/view/t;Landroid/view/WindowInsets;)V

    const/4 p1, 0x0

    iput-object p1, p0, Landroidx/core/view/t$j;->n:Landroidx/core/graphics/a;

    iput-object p1, p0, Landroidx/core/view/t$j;->o:Landroidx/core/graphics/a;

    iput-object p1, p0, Landroidx/core/view/t$j;->p:Landroidx/core/graphics/a;

    return-void
.end method

.method constructor <init>(Landroidx/core/view/t;Landroidx/core/view/t$j;)V
    .locals 0

    invoke-direct {p0, p1, p2}, Landroidx/core/view/t$i;-><init>(Landroidx/core/view/t;Landroidx/core/view/t$i;)V

    const/4 p1, 0x0

    iput-object p1, p0, Landroidx/core/view/t$j;->n:Landroidx/core/graphics/a;

    iput-object p1, p0, Landroidx/core/view/t$j;->o:Landroidx/core/graphics/a;

    iput-object p1, p0, Landroidx/core/view/t$j;->p:Landroidx/core/graphics/a;

    return-void
.end method


# virtual methods
.method h()Landroidx/core/graphics/a;
    .locals 1

    iget-object v0, p0, Landroidx/core/view/t$j;->o:Landroidx/core/graphics/a;

    if-nez v0, :cond_0

    iget-object v0, p0, Landroidx/core/view/t$g;->c:Landroid/view/WindowInsets;

    invoke-static {v0}, Landroidx/core/view/y;->a(Landroid/view/WindowInsets;)Landroid/graphics/Insets;

    move-result-object v0

    invoke-static {v0}, Landroidx/core/graphics/a;->d(Landroid/graphics/Insets;)Landroidx/core/graphics/a;

    move-result-object v0

    iput-object v0, p0, Landroidx/core/view/t$j;->o:Landroidx/core/graphics/a;

    :cond_0
    iget-object v0, p0, Landroidx/core/view/t$j;->o:Landroidx/core/graphics/a;

    return-object v0
.end method

.method j()Landroidx/core/graphics/a;
    .locals 1

    iget-object v0, p0, Landroidx/core/view/t$j;->n:Landroidx/core/graphics/a;

    if-nez v0, :cond_0

    iget-object v0, p0, Landroidx/core/view/t$g;->c:Landroid/view/WindowInsets;

    invoke-static {v0}, Landroidx/core/view/w;->a(Landroid/view/WindowInsets;)Landroid/graphics/Insets;

    move-result-object v0

    invoke-static {v0}, Landroidx/core/graphics/a;->d(Landroid/graphics/Insets;)Landroidx/core/graphics/a;

    move-result-object v0

    iput-object v0, p0, Landroidx/core/view/t$j;->n:Landroidx/core/graphics/a;

    :cond_0
    iget-object v0, p0, Landroidx/core/view/t$j;->n:Landroidx/core/graphics/a;

    return-object v0
.end method

.method l()Landroidx/core/graphics/a;
    .locals 1

    iget-object v0, p0, Landroidx/core/view/t$j;->p:Landroidx/core/graphics/a;

    if-nez v0, :cond_0

    iget-object v0, p0, Landroidx/core/view/t$g;->c:Landroid/view/WindowInsets;

    invoke-static {v0}, Landroidx/core/view/x;->a(Landroid/view/WindowInsets;)Landroid/graphics/Insets;

    move-result-object v0

    invoke-static {v0}, Landroidx/core/graphics/a;->d(Landroid/graphics/Insets;)Landroidx/core/graphics/a;

    move-result-object v0

    iput-object v0, p0, Landroidx/core/view/t$j;->p:Landroidx/core/graphics/a;

    :cond_0
    iget-object v0, p0, Landroidx/core/view/t$j;->p:Landroidx/core/graphics/a;

    return-object v0
.end method

.method public s(Landroidx/core/graphics/a;)V
    .locals 0

    return-void
.end method
