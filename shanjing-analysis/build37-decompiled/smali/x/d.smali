.class public final synthetic Lx/d;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic d:Lx/c$h;


# direct methods
.method public synthetic constructor <init>(Lx/c$h;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lx/d;->d:Lx/c$h;

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 1

    iget-object v0, p0, Lx/d;->d:Lx/c$h;

    invoke-static {v0}, Lx/c$h;->b(Lx/c$h;)V

    return-void
.end method
